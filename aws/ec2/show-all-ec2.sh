#!/usr/bin/env bash

# show all aws ec2 list

for region in $(aws ec2 describe-regions --query Regions[*].[RegionName] --output text); do
  echo -e "\nListing Instances in region: ${region}..."
  aws ec2 describe-instances --region ${region} | jq ".Reservations[].Instances[] | {type: .InstanceType, state: .State.Name, tags: .Tags, zone: .Placement.AvailabilityZone, privateIpAddress: .PrivateIpAddress, publicIpAddress: .PublicIpAddress }"
done

