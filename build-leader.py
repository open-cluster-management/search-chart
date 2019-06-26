import os
import logging

log = logging.getLogger("travis.leader")
log.addHandler(logging.StreamHandler())
log.setLevel(logging.INFO)

TRAVIS_JOB_NUMBER = 'TRAVIS_JOB_NUMBER'

def is_leader(job_number):
    return job_number.endswith('.1')


job_number = os.getenv(TRAVIS_JOB_NUMBER)

if not job_number:
    # seems even for builds with only one job, this won't get here
    log.fatal("Don't use defining leader for build without matrix")
    exit(1)
elif is_leader(job_number):
    with open(".to_export_back", "w") as export_var:
        export_var.write("BUILD_LEADER=YES")
    log.info("This is a leader")
else:
    # since python is subprocess, env variables are exported back via file
    with open(".to_export_back", "w") as export_var:
        export_var.write("BUILD_MINION=YES")
    log.info("This is a minion")
    exit(0)
