# Cloud Events

Keptn is capable of sending and consuming cloud events, allowing sequences to be triggered from requests to the keptn cli. To do this via keptn's API, we need a request with a JSON payload, such as:

```json
{
  "data": {
    "project": "demo",
    "service": "demo-svc",
    "stage": "dev",
    "foo": "bar"
  },
  "source": "https://github.com/keptn/keptn/cli#configuration-change",
  "specversion": "1.0",
  "type": "sh.keptn.event.dev.foo.triggered",
  "shkeptnspecversion": "0.2.3"
}
```

This event payload targets the `foo` sequence from the following shipyard:

```yaml
apiVersion: spec.keptn.sh/0.2.3
kind: "Shipyard"
metadata:
  name: "shipyard-demo-singlestage"
spec:
  stages:
    - name: "dev"
      sequences:
      - name: "delivery"
        tasks:
          - name: "deployment"
            properties:
              deploymentstrategy: "direct"
          - name: "release"
      - name: "foo"
        tasks:
          - name: "bar"
```

The `foo` sequence has a single task `bar`. When this sequence is triggered `sh.keptn.event.bar.triggered` will be fired. The Job Executor Service is waiting for that event, and responds with the task(s) that we've defined in that job.