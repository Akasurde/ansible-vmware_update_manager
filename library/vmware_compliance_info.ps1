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
        compliance_status = @{ type='str'; choices = "Compliant", "NotCompliant", "Unknown", "Incompatible"; }
        entity = @{ type='str'; }
        detailed = @{ type='bool'; }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)


$hostname = $module.Params.hostname
$username = $module.Params.username
$password = $module.Params.password
$port = $module.Params.port
$validate_certs = $module.Params.validate_certs

$entity = $module.Params.entity
$compliance_status = $module.Params.compliance_status
$detailed = $module.Params.detailed

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

$compliances_params = @{}

if ($entity) {
    $compliances_params.Entity = $entity
}

if ($compliance_status) {
    $compliances_params.ComplianceStatus = $compliance_status
}

if ($detailed) {
    $compliances_params.Detailed
}

$Compliances = Get-Compliance @compliances_params

$module.Result.compliance_info = [System.Collections.ArrayList]@()

foreach ($Compliance in $Compliances) {
    $compliance_info = @{
        status = $Compliance.Status
        baseline_name = $Compliance.Baseline.name
        baseline_description = $Compliance.Baseline.description
        baseline_type = $Compliance.Baseline.BaselineType
    }

    $module.Result.compliance_info.Add($compliance_info) > $null
}

$module.Result.changed = $false

$module.ExitJson()
