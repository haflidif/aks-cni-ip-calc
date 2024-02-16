#This script is used to calculate the number of IP addresses required for an Azure Kubernetes Service (AKS) cluster. 
#The input parameters are nodes, pods, scale, and ilbs. The nodes parameter is the number of nodes in the cluster. The pods parameter is the number of pods per node. The scale parameter is the number of replicas for each pod. The ilbs parameter is the number of internal load balancers in the cluster. 
#The output is the IP range with CIDR notation. 

<#
.SYNOPSIS
    Calculate the number of IP addresses required for an Azure Kubernetes Service (AKS) cluster.
.DESCRIPTION
    This command calculates the number of IP addresses required for an Azure Kubernetes Service (AKS) cluster based on the number of nodes, pods, scale, and internal load balancers (ILBs).
.PARAMETER Nodes
    The number of nodes in the AKS cluster.
.PARAMETER Pods
    The number of pods per node in the AKS cluster.
.PARAMETER Scale
    The number of replicas for each pod in the AKS cluster.
.PARAMETER Ilbs
    The number of internal load balancers (ILBs) in the AKS cluster.
.PARAMETER Json
    Return the results in JSON format.
.EXAMPLE
    Get-AksIP -Nodes 10 -Pods 100 -Scale 2 -Ilbs 2
    This command calculates the number of IP addresses required for an AKS cluster with 10 nodes, 100 pods per node, 2 replicas for each pod, and 2 ILBs.
.EXAMPLE
    Get-AksIP -Nodes 10 -Pods 100 -Scale 2 -Ilbs 2 -Json
    This command calculates the number of IP addresses required for an AKS cluster with 10 nodes, 100 pods per node, 2 replicas for each pod, and 2 ILBs and returns the results in JSON format.
#>

[CmdletBinding()]
param (
    [Parameter()]
    [int]
    $nodes,
    [Parameter()]
    [int]
    $pods,
    [Parameter()]
    [int]
    $scale,
    [Parameter()]
    [int]
    $ilbs,
    [Parameter()]
    [switch]
    $json
)

# Validate the input parameters
if ($nodes -eq 0) {
    throw "Please provide at least one node to calculate the number of IP addresses required for an AKS cluster."
}
if ($nodes + $scale -gt 1000) {
    throw "Node number is higher than the supported limit of 1000 nodes per cluster."
}
if ($pods -gt 250) {
    throw "Pod number is higher than the supported limit of 250 per node."
}
if ($pods -lt 30) {
    $pods = 30
}

# Function to calculate the CIDR notation
function Get-IpRangeWithCidr {
    param (
        [int]$TotalHosts
    )

    # Calculate the number of bits required for the host portion
    $BitsForHosts = [math]::Ceiling([math]::Log($TotalHosts, 2))
    
    # Calculate the CIDR notation
    $Cidr = 32 - $BitsForHosts
    
    return "/$Cidr"
}

<# 
    Calls an Azure Function from https://www.danielstechblog.io/updated-azure-function-app-aks-advanced-networking-ip-address-calculation/ to calculate the number of IP addresses required for an AKS cluster
    The API endpoint is https://akscnicalc.azurewebsites.net/api/akscnicalc
    The input parameters are nodes, pods, scale, and ilbs
    The output is total IP Addresses required for the AKS cluster, with addtional information like nodes, pods, scale, and ilbs
    The output is in JSON format
#>

$getaksip = curl "https://akscnicalc.azurewebsites.net/api/akscnicalc?nodes=$($Nodes)&pods=$($Pods)&scale=$($scale)&ilbs=$($ilbs)" --silent | ConvertFrom-Json

# Calling the function to calculate the CIDR notation
$ipaddresses = $getaksip.ipaddresses
$cidrNotation = Get-IpRangeWithCidr -TotalHosts $ipaddresses

# Create an object to return the results
$object = [PSCustomObject]@{
    Nodes                = $getaksip.nodes
    Pods                 = $getaksip.pods
    Scale                = $getaksip.scale
    ILBs                 = $getaksip.ilbs
    'Total IP Addresses' = $ipaddresses
    'CIDR Notation'      = $cidrNotation
}

if ($json) {
    # Create a new object with the spaces removed from the property names to convert to JSON
    $jsonObject = $object | ForEach-Object {
        $newObject = New-Object PSObject
        $_.PSObject.Properties | ForEach-Object {
            $newObject | Add-Member -NotePropertyName ($_.Name -replace ' ', '').ToLower() -NotePropertyValue $_.Value
        }
        $newObject
    }

    # Convert the new object to a JSON string
    return $jsonObject | ConvertTo-Json
}
else {
    return $object
}
