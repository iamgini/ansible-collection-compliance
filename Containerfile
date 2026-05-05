FROM quay.io/ansible/creator-ee:latest

USER root

# Install OpenSCAP tools for compliance scanning
RUN microdnf install -y \
    openscap-scanner \
    scap-security-guide \
    openscap-utils \
    git \
    && microdnf clean all

# Install Python dependencies
RUN pip3 install --no-cache-dir lxml>=4.9.0

# Install required Ansible collections
RUN ansible-galaxy collection install ansible.posix \
    && ansible-galaxy collection install community.general \
    && ansible-galaxy collection install ansible.utils

USER 1000

LABEL name="compliance-ee" \
      description="Execution environment for OpenSCAP compliance scanning" \
      version="1.0"
