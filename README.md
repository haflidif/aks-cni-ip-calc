# aks-cni-ip-calc
Calculate the number of IP addresses required for an Azure Kubernetes Service (AKS) cluster.

## Description
`Get-AksIP.ps1`, is designed to calculate the number of IP addresses required for an Azure Kubernetes Service (AKS) cluster with the Azure CNI network plugin. The script takes into account the number of nodes, the number of pods per node, the number of replicas for each pod, and the number of internal load balancers in the cluster. It returns the total number of IP addresses required and the CIDR notation for the AKS cluster. The script can also return the result in JSON format if the `-json` switch is used.

## Parameters

- `nodes`: The number of nodes in the AKS cluster.
- `pods`: The number of pods per node.
- `scale`: The number of replicas for each pod.
- `ilbs`: The number of internal load balancers in the cluster.
- `json`: If this switch is used, the result is returned in JSON format.

## Usage

```powershell
.\Get-AksIP.ps1 -nodes 50 -pods 30 -scale 10 -ilbs 1
```

## Output

The script returns an object with the following properties:

```powershell
Nodes              : 50
Pods               : 30
Scale              : 10
ILBs               : 1
Total IP Addresses : 1892
CIDR Notation      : /21
```

The script also returns the result in JSON format if the `-json` switch is used:

```powershell
.\Get-AksIP.ps1 -nodes 50 -pods 30 -scale 10 -ilbs 1 -json
```

```json
{
  "nodes": 50,
  "pods": 30,
  "scale": 10,
  "ilbs": 1,
  "totalipaddresses": 1892,
  "cidrnotation": "/21"
}
```

## Author

Originally authored by: [Haflidi Fridthjofsson](https://github.com/haflidif)

> _Credit to: [Daniel Neumann](https://github.com/neumanndaniel) for providing the Azure Function API to calculate the IP addresses required for an AKS cluster._
