# Aggregation

Snapshots provide the best historical data on voters.  Traversing them in their entirety is expensive.  Therefore we attempt to normalize into unique attributes and common relations

Our main sources of interest are

* ncvoter (For current voter information)
  * Some dirty data due to folks that recently changed counties
* ncvhis (For past 10 years of voting behavior)
* Snapshots/VR\_Snapshot*
  * Lots of dirty data in older (CLeaned)
  * Lots of noise with deceased voters and moves

## Unique patterns

### Voter ncvoter, vr\_snapshot

Data gets dirty due to clerical errors and moves between counties.

Key fields

* county\_id (Voter's county)
* voter\_reg\_num (Voter's registration number within the county)
* ncid (State wide ID for voter.  May be duplicated due to move or other changes)

### Snapshot Date vr\_snapshot

Loads were redone when the format changed

Key fields
* snapshot\_dt
* load\_dt

### Residence vr\_snapshot, ncvoter

There is a subtle difference between these two files.  

In vr\_snapshot the address is completely deconstructed

* house\_num
* half\_code
* street\_dir
* street\_name
* street\_type\_cd
* street\_sufx\_cd
* unit\_designator (Not used)
* unit\_num

In ncvoter it is

* res\_street\_address

Then there is the common

* res\_city\_desc
* state\_cd
* zip\_code

There are about 200K res\_street\_addresses in multiple cities

Focus on vr\_snapshot at first.  Provide a view to convert to ncvoter later

### Name (Snapshot) vr\_snapshot

* name\_prefx\_cd (not used)
* last\_name
* first\_name
* midl\_name (middle\_name in ncvoter)
* name\_sufx\_cd (ncvoter is different)

Adding race creates more records than adding sex

### Demographics (Snapshot) vr\_snapshot

Demographics on age are a bitch because ncvoter has birth\_year and age at year end
while vr\_snapshot has age at time of snapshot (sort of).  For that strategy to work later...

Interesting fields

* race\_code
* ethnic\_code
* party\_cd
* sex\_code

(239 unique)

Adding 

* status\_cd
* reason\_cd

Increases that to 3838

Adding birth\_place

Increases that to 49684

## Relations

### Voter Residence Name (Snapshot)

This should be sufficient for tracking most name changes.
