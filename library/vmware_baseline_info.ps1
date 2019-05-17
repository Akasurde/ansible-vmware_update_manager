#!powershell

# Copyright: (c) 2019, Abhijeet Kasurde (@Akasurde) <akasurde@redhat.com>

#AnsibleRequires -CSharpUtil Ansible.Basic
#Requires -Module Ansible.ModuleUtils.ArgvParser
#Requires -Module Ansible.ModuleUtils.CommandUtil
#Requires -Module VMware.VumAutomation

Import-module VMware.VumAutomation

$spec = @{
    options = @{
        hostname = @{ type='str'; }
        username = @{ type='str'; }
        password = @{ type='str'; }
        port = @{ type='str'; default = 443; }
        validate_certs = @{ type='str'; default = $true }
        target_type = @{ type='str'; choices = "VM", "Host", "VA"; }
        baseline_type = @{ type='str'; choices = "Patch", "Upgrade"; }
        baseline_content_type = @{ type='str'; choices = "Dynamic", "Static", "Both"; }
        entity = @{ type='str'; choices = "Template", "VirtualMachine", "VMHost", "Cluster", "Datacenter", "Folder", "VApp"; }
        baseline_id = @{ type='int'; }
        inherit = @{ type='bool'; }
        recurse = @{ type='bool'; }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)


$hostname = $module.Params.hostname
$username = $module.Params.username
$password = $module.Params.password
$validate_certs = $module.Params.validate_certs
$port = $module.Params.port
$target_type = $module.params.target_type
$baseline_type = $module.params.baseline_type
$baseline_content_type = $module.params.baseline_content_type
$baseline_id = $module.params.baseline_id
$inherit = $module.params.inherit
$recurse = $module.params.recurse

if (-not $hostname) {
    $hostname = [Environment]::GetEnvironmentVariable('VMWARE_HOST')
    if (-not $hostname) {
        $module.FailJson("Hostname parameter is missing. Please specify this parameter in task or export environment variable 'VMWARE_HOST'")
    }
}

if (-not $username) {
    $username = [Environment]::GetEnvironmentVariable('VMWARE_USER')
    if (-not $username) {
        $module.FailJson("Username parameter is missing. Please specify this parameter in task or export environment variable 'VMWARE_USER'")
    }
}

if (-not $password) {
    $password = [Environment]::GetEnvironmentVariable('VMWARE_PASSWORD')
    if (-not $password) {
        $module.FailJson("Password parameter is missing. Please specify this parameter in task or export environment variable 'VMWARE_PASSWORD'")
    }
}

$env_validate_certs = [Environment]::GetEnvironmentVariable('VMWARE_VALIDATE_CERTS')
if ($env_validate_certs -ne $null) {
    $validate_certs = $env_validate_certs
}

$env_port = [Environment]::GetEnvironmentVariable('VMWARE_PORT')
if ($env_port -ne $null) {
    $port = $env_port
}

if (-not $validate_certs) {
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
}

$module.Result.rc = 0

Connect-VIServer $hostname -User $username -Password $password -Port $port

$baseline_params = @{}

if ($target_type) {
    $baseline_params.TargetType = $target_type
}

if ($baseline_type) {
    $baseline_params.BaselineType = $baseline_type
}

if ($baseline_content_type) {
    $baseline_params.BaselineContentType = $baseline_content_type
}

if ($baseline_id) {
    $baseline_params.Id = $baseline_id
}

if ($inherit) {
    $baseline_params.Inherit
}

if ($recurse) {
    $baseline_params.Recurse
}

$Baselines = Get-Baseline @baseline_params

$module.Result.baseline_info = [System.Collections.ArrayList]@()

foreach ($Baseline in $Baselines) {
    $baseline_info = @{
        name = $Baseline.Name
        description = $Baseline.Description
        id = $Baseline.Id
        target_type = $Baseline.TargetType
        baseline_content_type = $Baseline.BaselineContentType
        baseline_type = $Baseline.BaselineType
        is_system_defined = $Baseline.IsSystemDefined
        target_component = $Baseline.TargetComponent
        current_patches = $Baseline.CurrentPatches
    }

    $module.Result.baseline_info.Add($baseline_info) > $null
}

$module.Result.changed = $false

$module.ExitJson()
