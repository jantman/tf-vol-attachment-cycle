# tf-vol-attachment-cycle

Proof-of-concept for Terraform (0.10.6) [issue TBD](https://github.com/hashicorp/terraform/issues/TBD).

cycle detected when an ``aws_instance`` resource with a ``when = "destroy"`` provisioner
needs to be replaced (i.e. from user-data change) and there is a ``aws_volume_attachment``
resource that references it.

## Running Example Code

1. Clone this repo.
2. Export AWS credentials
3. ``AWS_REGION=region_name SUBNET_ID=subnet-XXXX ./run.sh``

## Output

With the local-exec provisioner (on destroy), it fails with a cycle
(``Cycle: aws_instance.ecs-instance (destroy), aws_instance.ecs-instance``): [with_local_exec.txt](with_local_exec.txt).

If we remove the:

```
provisioner "local-exec" {
  when    = "destroy"
  command = "${path.module}/instance-destroy.sh '${aws_instance.ecs-instance.public_ip}' '${var.persistent_ebs_mountpoint}'"
}
```

block from the ``aws_instance`` resource and re-run, it works fine: [without_local_exec.txt](without_local_exec.txt).
