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
module: vmware_baseline_info
version_added: '2.9'
short_description: Gather information about the baselines specified by the provided parameters.
description:
- This module can be used to gather information about the baselines specified.
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
    target_type:
      description:
      - Specify the target type of the baselines you want to retrieve.
      type: str
      choices: [ VM, Host, VA ]
      required: False
    baseline_type:
      description:
      - Specify the type of the baselines you want to retrieve.
      type: str
      choices: [ Patch, Upgrade ]
      required: False
    baseline_content_type:
      description:
      - Specify the content type of the baselines you want to retrieve.
      type: str
      choices: [ Dynamic, Static, Both ]
      required: False
    entity:
      description:
      - Specify entity object to which the baselines you want to retrieve are attached.
      type: str
      required: False
    baseline_id:
      description:
      - Specify the IDs of the baselines you want to retrieve.
      type: int
      required: False
    inherit:
      description:
      - Specify that you want to retrieve the baselines inherited by the parent inventory entities.
      type: bool
      required: False
      default: False
    recurse:
      description:
      - Specify that you want to retrieve the baselines attached to the child inventory entities.
      type: bool
      required: False
      default: False
author:
- Abhijeet Kasurde (@Akasurde)
'''

EXAMPLES = r'''
- name: Get information about Baselines
  vmware_baseline_info:
    hostname: '{{ vcenter_hostname }}'
    username: '{{ vcenter_username }}'
    password: '{{ vcenter_password }}'
    validate_certs: no
  register: base_info

'''

RETURN = r'''
baseline_info:
    description: metadata about the baseline information
    returned: always
    type: complex
    sample: [
            {
                "baseline_content_type": 1,
                "baseline_type": 1,
                "current_patches": null,
                "description": "A predefined baseline for VA Upgrade to Latest Version",
                "id": 5,
                "is_system_defined": true,
                "name": "VA Upgrade to Latest (Predefined)",
                "target_component": 2,
                "target_type": 2
            },
            {
                "baseline_content_type": 1,
                "baseline_type": 1,
                "current_patches": null,
                "description": "A pre-defined baseline for upgrading to the latest VMware Tools version supported by the host",
                "id": 3,
                "is_system_defined": true,
                "name": "VMware Tools Upgrade to Match Host (Predefined)",
                "target_component": 5,
                "target_type": 1
            },
    ]
'''
