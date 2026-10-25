// Copyright (C) 2026 AHMAD ALI PARR
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
use reqwest::Client;
use serde::{Deserialize, Serialize};

#[derive(Serialize)]
struct TavilyRequest {
    api_key: String,
    query: String,
    search_depth: String,
    include_answer: bool,
}

#[derive(Deserialize)]
pub struct TavilyHit {
    pub title: String,
    pub url: String,
    pub content: String,
}

#[derive(Deserialize)]
pub struct TavilyResult {
    pub answer: Option<String>,
    pub results: Vec<TavilyHit>,
}

pub struct TavilyClient {
    client: Client,
    api_key: String,
}

impl TavilyClient {
    pub fn new(api_key: impl Into<String>) -> Self {
        Self {
            client: Client::new(),
            api_key: api_key.into(),
        }
    }

    pub async fn search(&self, query: &str) -> anyhow::Result<TavilyResult> {
        let req = TavilyRequest {
            api_key: self.api_key.clone(),
            query: query.to_string(),
            search_depth: "advanced".into(),
            include_answer: true,
        };
        let resp = self
            .client
            .post("https://api.tavily.com/search")
            .json(&req)
            .send()
            .await?
            .error_for_status()?;
        Ok(resp.json().await?)
    }
}
