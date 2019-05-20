#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: 2019, Abhijeet Kasurde (@Akasurde) <akasurde@redhat.com>
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

ANSIBLE_METADATA = {
    'metadata_version': '1.1',
    'status': ['preview'],
    'supported_by': 'community'
}

DOCUMENTATION = r'''
---
module: vmware_compliance_info
version_added: '2.9'
short_description: Gather baseline compliance data for the specified object of type.
description:
- This module can be used to gather baseline compliance data for the specified object of type.
options:
    hostname:
      description:
      - The hostname or IP address of the vSphere vCenter or ESXi server.
      - If the value is not specified in the task, the value of environment variable C(VMWARE_HOST) will be used instead.
      type: str
    username:
      description:
      - The username of the vSphere vCenter or ESXi server.
      - If the value is not specified in the task, the value of environment variable C(VMWARE_USER) will be used instead.
      type: str
      aliases: [ admin, user ]
    password:
      description:
      - The password of the vSphere vCenter or ESXi server.
      - If the value is not specified in the task, the value of environment variable C(VMWARE_PASSWORD) will be used instead.
      type: str
      aliases: [ pass, pwd ]
    validate_certs:
      description:
      - Allows connection when SSL certificates are not valid. Set to C(false) when certificates are not trusted.
      - If the value is not specified in the task, the value of environment variable C(VMWARE_VALIDATE_CERTS) will be used instead.
      type: bool
      default: yes
    port:
      description:
      - The port number of the vSphere vCenter or ESXi server.
      - If the value is not specified in the task, the value of environment variable C(VMWARE_PORT) will be used instead.
      type: int
      default: 443
    compliance_status:
      description:
      - Specify the status of the compliance you want to retrieve.
      type: str
      choices: [ Compliant, NotCompliant, Unknown, Incompatible ]
    entity:
      description:
      - Specify entity object for which you want to retrieve the compliance status.
      type: str
      required: False
    detailed:
      description:
      - Specify that you want to retrieve detailed information about the compliance.
      type: bool
      required: False
      default: False
author:
- Abhijeet Kasurde (@Akasurde)
'''

EXAMPLES = r'''
- name: Get information about Compliances
  vmware_compliance_info:
    hostname: '{{ vcenter_hostname }}'
    username: '{{ vcenter_username }}'
    password: '{{ vcenter_password }}'
    validate_certs: no
    entity: '{{ esxi_hostname }}'
  register: base_info

'''

RETURN = r'''
compliance_info:
    description: metadata about the compliance information
    returned: always
    type: complex
    sample: [
      {
        "baseline_description": "A predefined baseline for all non-critical patches for Hosts",
        "baseline_name": "Non-Critical Host Patches (Predefined)",
        "baseline_type": 0,
        "status": 2
      }
    ]
'''
