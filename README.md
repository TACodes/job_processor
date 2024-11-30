# JobProcessor
---

## Instructions to Run

### 1. Start the Phoenix Server
Run the following command:
```bash
mix phx.server
```

### 2. Send Test Requests
You can send requests to the API using `curl` or tools like Postman.

### Example Request and Testing

#### Sample curl Request
```bash
curl -X POST http://localhost:4000/api/process \
-H "Content-Type: application/json" \
-d '{
  "tasks": [
    {
      "name": "task-4",
      "command": "rm /tmp/file1",
      "requires": [ "task-2", "task-3" ]
    },
    {
      "name": "task-2",
      "command": "cat /tmp/file1",
      "requires": [ "task-3" ]
    },
    {
      "name": "task-3",
      "command": "echo \"Hello World!\" > /tmp/file1",
      "requires": [ "task-1" ]
    },
    {
      "name": "task-1",
      "command": "touch /tmp/file1"
    }
  ]
}'
```

#### Sample Response
```json
{
  "tasks": [
    { "name": "task-1", "command": "touch /tmp/file1" },
    { "name": "task-3", "command": "echo \"Hello World!\" > /tmp/file1" },
    { "name": "task-2", "command": "cat /tmp/file1" },
    { "name": "task-4", "command": "rm /tmp/file1" }
  ],
  "script": "#!/usr/bin/env bash\ntouch /tmp/file1\necho \"Hello World!\" > /tmp/file1\ncat /tmp/file1\nrm /tmp/file1\n"
}
```

### 3. Validate the Script Output
The generated script output from the response is saved to a file (e.g., `script.sh`).

Execute it:
`./script.sh`

