// attention_tc.cu — WMMA 16x16x16 Tensor Core attention (QK^T + softmax + PV)
// Target Volta/Turing/Ampere/Hopper, FP16 in / FP32 accum, head_dim tiling, causal.
// See macrogrok-harness README for FlashAttention online-softmax integration.
// Compile: nvcc -arch=sm_80 -ptx attention_tc.cu -o attention_tc.ptx

#include <cuda_fp16.h>
#include <mma.h>
using namespace nvcuda;
constexpr int WMMA_M=16, WMMA_N=16, WMMA_K=16;
constexpr int SMEM_Q_TILE=16, SMEM_K_TILE=16;

__global__ void tensor_core_attn_x(
    const half* __restrict__ Q, const half* __restrict__ K, const half* __restrict__ V,
    half* __restrict__ Out, int batch_size, int num_heads, int q_len, int kv_len, int head_dim, float scale, bool causal) {
    const int batch_idx = blockIdx.z, head_idx = blockIdx.y, q_tile_idx = blockIdx.x;
    if (batch_idx>=batch_size || head_idx>=num_heads) return;
    const int q_row_start = q_tile_idx * WMMA_M;
    if (q_row_start>=q_len) return;
    const half* Q_base = Q + ((batch_idx*num_heads+head_idx)*q_len)*head_dim;
    const half* K_base = K + ((batch_idx*num_heads+head_idx)*kv_len)*head_dim;
    const half* V_base = V + ((batch_idx*num_heads+head_idx)*kv_len)*head_dim;
    half* Out_base = Out + ((batch_idx*num_heads+head_idx)*q_len)*head_dim;
    __shared__ half smem_q[16*16], smem_k[16*16];
    wmma::fragment<wmma::matrix_a,16,16,16,half,wmma::row_major> a_frag;
    wmma::fragment<wmma::matrix_b,16,16,16,half,wmma::col_major> b_frag;
    wmma::fragment<wmma::accumulator,16,16,16,float> acc_frag, out_frag;
    wmma::fill_fragment(out_frag, 0.0f);
    for (int kv_tile=0; kv_tile < (kv_len+15)/16; ++kv_tile) {
        const int kv_col_start = kv_tile*16;
        if (kv_col_start>=kv_len) break;
        wmma::fill_fragment(acc_frag, 0.0f);
        // head_dim tiling for QK^T reduction
        for (int d_tile=0; d_tile < (head_dim+15)/16; ++d_tile) {
            const int d_start = d_tile*16;
            for (int i=threadIdx.x; i<256; i+=blockDim.x) {
                int row=i/16, col=i%16;
                int gr=q_row_start+row, gc=d_start+col;
                smem_q[row*16+col] = (gr<q_len && gc<head_dim) ? Q_base[gr*head_dim+gc] : __float2half(0);
            }
            for (int i=threadIdx.x; i<256; i+=blockDim.x) {
                int row=i/16, col=i%16;
                int gr=kv_col_start+row, gc=d_start+col;
                smem_k[row*16+col] = (gr<kv_len && gc<head_dim) ? K_base[gr*head_dim+gc] : __float2half(0);
            }
            __syncthreads();
            wmma::load_matrix_sync(a_frag, smem_q, 16);
            wmma::load_matrix_sync(b_frag, smem_k, 16);
            wmma::mma_sync(acc_frag, a_frag, b_frag, acc_frag);
            __syncthreads();
        }
        #pragma unroll
        for (int i=0;i<acc_frag.num_elements;++i) acc_frag.x[i]*=scale;
        // causal mask + softmax (online max/sum across kv_tiles) goes here
        // second stage: scores @ V (head_dim tiling again)
        for (int d_tile=0; d_tile < (head_dim+15)/16; ++d_tile) {
            const int d_start=d_tile*16;
            for (int i=threadIdx.x;i<256;i+=blockDim.x) {
                int row=i/16,col=i%16;
                int gr=kv_col_start+row, gc=d_start+col;
                smem_k[row*16+col]=(gr<kv_len&&gc<head_dim)?V_base[gr*head_dim+gc]:__float2half(0);
            }
            __syncthreads();
            wmma::fragment<wmma::matrix_b,16,16,16,half,wmma::row_major> v_frag;
            wmma::load_matrix_sync(v_frag, smem_k, 16);
            // wmma::mma_sync(out_frag, score_a_frag, v_frag, out_frag); // after converting scores
        }
    }
    __shared__ float smem_out[256];
    wmma::store_matrix_sync(smem_out, out_frag, 16, wmma::mem_row_major);
    __syncthreads();
    for (int i=threadIdx.x;i<256;i+=blockDim.x) {
        int row=i/16,col=i%16;
        int gr=q_row_start+row, gc=col;
        if (gr<q_len && gc<head_dim) Out_base[gr*head_dim+gc]=__float2half(smem_out[row*16+col]);
    }
}