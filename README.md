# tf-vol-attachment-cycle

Proof-of-concept for Terraform issue X

cycle detected when an ``aws_instance`` resource needs to be replaced (i.e. from user-data change)
but there is a ``aws_volume_attachment`` resource that references it.

## Running Example Code

1. Clone this repo.
2. Export AWS credentials
3. ``AWS_REGION=region_name ./run.sh``
4. ``terraform destroy``

## Output

* With the local-exec provisioner (on destroy): [with_local_exec.txt](with_local_exec.txt)
