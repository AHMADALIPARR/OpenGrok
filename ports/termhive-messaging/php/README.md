# TermHive Messaging — PHP Port

Port of the agent-to-agent messaging system from https://github.com/0x0funky/TermHive

## What was ported

Same contract as the Elixir port:

- `messageAgent($fromId, $targetQuery, $message)` — fuzzy match + inject
- `listTeammates($agentId)`
- Activity log
- Configurable injector (default: log)

## Usage

```php
require 'src/Messaging.php';

$m = new TermHive\Messaging();

$m->registerAgent([
    'id' => 'a1', 'project_id' => 'p1', 'name' => 'Frontend', 'role' => 'ui', 'cli' => 'claude'
]);
$m->registerAgent([
    'id' => 'a2', 'project_id' => 'p1', 'name' => 'Backend', 'role' => 'api', 'cli' => 'codex'
]);

$result = $m->messageAgent('a1', 'backend', 'API is done');
// $result['delivered'] === true

print_r($m->listTeammates('a1'));
```

## Injection

```php
$m->setInjector(function ($agentId, $text) {
    // write $text into the agent's input / process stdin / queue
});
```
