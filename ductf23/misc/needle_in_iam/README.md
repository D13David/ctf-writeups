# DownUnderCTF 2023

## Needle In IAM

> I've been told the flag I need is in description of this role, but I keep getting an error with the following command. Surely there's another way?
> 
> `gcloud iam roles describe ComputeOperator --project=<PROJECT>`
>
>  Author: BootlegSorcery@
>
> [`credentials.json`](credentials.json)

Tags: _misc_

## Solution
This is a `GCP` challenge. We are presented with credentials for a service account. So activating the credentials and calling the command to describe the iam role indeed gives us `permission denied`.

```bash
$ gcloud auth activate-service-account --key-file=credential.json

$ gcloud iam roles describe ComputeOperator --project=needle-in-iam
ERROR: (gcloud.iam.roles.describe) PERMISSION_DENIED: You don't have permission to get the role at projects/needle-in-iam/roles/ComputeOperator.
- '@type': type.googleapis.com/google.rpc.ErrorInfo
  domain: iam.googleapis.com
  metadata:
    permission: iam.roles.get
    resource: projects/needle-in-iam/roles/ComputeOperator
  reason: IAM_PERMISSION_DENIED
```

But what we can do is list all the roles:

```bash
$ gcloud iam roles list --project=needle-in-iam
---
description: Enables managing and configuring Azure Active Directory resources.
etag: BwYDv1zJ7TI=
name: projects/needle-in-iam/roles/ADAdmin
stage: GA
title: Azure Active Directory Administrator
---

...

description: DUCTF{D3scr1be_L1ST_Wh4ts_th3_d1fference_FDyIMbnDmX}
etag: BwYDv1xX9Y4=
name: projects/needle-in-iam/roles/ComputeOperator
stage: GA
title: Compute Operator
---
```

And there we get the flag in the role description.

Flag `DUCTF{D3scr1be_L1ST_Wh4ts_th3_d1fference_FDyIMbnDmX}`