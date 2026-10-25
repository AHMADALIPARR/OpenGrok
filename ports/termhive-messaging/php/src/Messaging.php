<?php
namespace TermHive;

/**
 * TermHive agent messaging — PHP port.
 * Matches the Elixir and original TypeScript contracts.
 */
class Messaging
{
    private array $agents = [];
    private array $activity = [];
    private $injector;

    public function __construct()
    {
        $this->injector = function (string $agentId, string $text) {
            error_log("[inject → {$agentId}] {$text}");
        };
    }

    public function setInjector(callable $fn): void
    {
        $this->injector = $fn;
    }

    public function registerAgent(array $agent): void
    {
        $this->agents[$agent['id']] = $agent;
    }

    public function unregisterAgent(string $id): void
    {
        unset($this->agents[$id]);
    }

    public function messageAgent(string $fromId, string $targetQuery, string $message): array
    {
        if (!isset($this->agents[$fromId])) {
            return ['ok' => false, 'error' => 'unknown_sender'];
        }

        $from = $this->agents[$fromId];
        $teammates = array_filter(
            $this->agents,
            fn($a) => $a['project_id'] === $from['project_id'] && $a['id'] !== $fromId
        );

        $target = $this->resolveTarget($teammates, $targetQuery);
        if (!$target) {
            return ['ok' => false, 'error' => 'no_match'];
        }

        $text = "[Message from {$from['name']}]: {$message}";
        ($this->injector)($target['id'], $text);

        $this->activity[] = [
            'id' => bin2hex(random_bytes(8)),
            'project_id' => $from['project_id'],
            'event' => 'agent_message',
            'from_agent' => $from['name'],
            'to_agent' => $target['name'],
            'message' => $message,
            'timestamp' => date('c'),
        ];

        return ['ok' => true, 'delivered' => true, 'to' => $target['name']];
    }

    public function listTeammates(string $agentId): array
    {
        if (!isset($this->agents[$agentId])) {
            return [];
        }
        $agent = $this->agents[$agentId];
        $out = [];
        foreach ($this->agents as $a) {
            if ($a['project_id'] === $agent['project_id'] && $a['id'] !== $agentId) {
                $out[] = [
                    'id' => $a['id'],
                    'name' => $a['name'],
                    'role' => $a['role'] ?? null,
                    'cli' => $a['cli'] ?? null,
                ];
            }
        }
        return $out;
    }

    public function recentActivity(int $limit = 50): array
    {
        return array_slice(array_reverse($this->activity), 0, $limit);
    }

    private function resolveTarget(array $teammates, string $query): ?array
    {
        $q = strtolower($query);
        foreach ($teammates as $a) {
            $name = strtolower($a['name']);
            $role = isset($a['role']) ? strtolower($a['role']) : '';
            if ($name === $q || $role === $q || str_contains($name, $q) || ($role && str_contains($role, $q))) {
                return $a;
            }
        }
        return null;
    }
}
