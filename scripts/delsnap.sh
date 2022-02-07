\#!/bin/bash
CURRENT_DATE=$(($(date +%s)))
echo "Removing all snapshots older than a week"
RG_LIST=("MC_AKS_AKSDEMO_WESTEUROPE ")
for RG in ${RG_LIST[@]}; do
    az snapshot list --resource-group=$RG > snapshots.json
    SNAPSHOTS_LENGTH=$(jq length snapshots.json)
    echo "SWITCHING TO RG $RG containing $SNAPSHOTS_LENGTH snapshots"
    i=0
    while [ "$i" -lt $SNAPSHOTS_LENGTH ]; do
        TIME_CREATED=$(jq .[$i].timeCreated snapshots.json)
        TIME_CREATED=${TIME_CREATED:1:10}
        DATE_CREATED=$TIME_CREATED
        TIME_CREATED=$(date -d $TIME_CREATED +%s)
        let TIME_DIFF=$CURRENT_DATE-$TIME_CREATED
        UNIQUE_ID=$(jq .[$i].uniqueId snapshots.json)
        NAME=$(jq .[$i].name snapshots.json)
        sed -e 's/^"//' -e 's/"$//' <<<"$NAME"
        STATE=$(jq .[$i].diskState snapshots.json)
        if [[ "$TIME_DIFF" -gt 610 ]]; #610000 is about a week
        then
            echo "Deleting $UNIQUE_ID with name $NAME created on $DATE_CREATED in $RG group"
            #echo Name: $NAME
            NEW_NAME="${NAME:1:${#NAME}-2}"
            echo RG: $RG
            echo $NAME
            echo $NEW_NAME
            #echo $TIME_DIFF
            az snapshot delete --name $NEW_NAME --resource-group $RG
#           #az snapshot wait --deleted --name $NAME --resource-group $RG
        else
            echo "Ignoring snapshot $NAME"
        fi
        i=$(( i + 1 ))
    done
    az snapshot list --resource-group=$RG > new.json
    NEW_SNAPSHOTS_LENGTH=$(jq length new.json)
    let SNAPSHOTS_DIFF=$SNAPSHOTS_LENGTH-$NEW_SNAPSHOTS_LENGTH
    echo "RG $RG now contains $NEW_SNAPSHOTS_LENGTH snapshot(s) - Deleted $SNAPSHOTS_DIFF snapshot(s)"
done
