# Project Thunderhead
A Simple and Comprehesive monitoring solution

Core Functions
- Performance
- Availablity
- Backups
- Auditing

## Version 1.0

Scripts will primarily be in Bash. Jobs will be triggered by Cron.
The first script, Oculus, will focus on capturing the server at a point in time.

### Oculus

At a given interval (1hr), it will capture the output of multiple performance commands.

## Directory Structure

```
.../th/
    |- logs/
    |    |-- (YYYY-MM-DD-HH:MM:SS).tz.xy
    |    |-- (YYYY-MM-DD-HH:MM:SS).tz.xy
    |    |-- ...
    |
    |- config.json
    |...
```