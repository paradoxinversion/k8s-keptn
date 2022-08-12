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

# Sending events to initiate Keptn Jobs

Events can be sent one of two ways, either Keptn's CLI or API. Under the hood, Keptn calls the API either way. The requirement for requests can be found in the swagger docs. The above JSON meets the requirements for such a request.

# Building the Sequences

A few things are needed for this to work. First, the Job Executor Service must be installed. Next, the project (demo) must include a sequence (foo), with task (bar) for the job to run against. Next, a job that targets that task abd trigger must be added as a resource.

# Structuring containers for sequences

As long as a container can communicate with the keptn api, it can make requests to it, thereby allowing it to trigger sequences. In the end, what matters here is the data passed from the other container. The Keptn job can handle whatever steps we want to act upon with the data it receives.

# Calling Additional Events from Sequences

Since a Keptn job uses a container, we can make additional requests to the api from those jobs. This requires additional setup depending on how keptn is set up. 