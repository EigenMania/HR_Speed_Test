using Toybox.System;

module HR_Speed_Test_Logger 
{
    // Logger verbosity levels.
    // Levels lower than and equal to the set level
    // will be written to the console. 
    enum
    {
        LOG_LEVEL_0, // No logging
        LOG_LEVEL_1,
        LOG_LEVEL_2,
        LOG_LEVEL_3,
        LOG_LEVEL_4
    }

    // Default to log everything.
    var loggerLevel = LOG_LEVEL_4;

    function LOG1(string) {
        if (LOG_LEVEL_1 <= loggerLevel) {
            cout(string);
        }
    }

    function LOG2(string) {
        if (LOG_LEVEL_2 <= loggerLevel) {
            cout(string);
        }
    }

    function LOG3(string) {
        if (LOG_LEVEL_3 <= loggerLevel) {
            cout(string);
        }
    }

    function LOG4(string) {
        if (LOG_LEVEL_4 <= loggerLevel) {
            cout(string);
        }
    }

    function cout(string) {
        var msTime = System.getTimer();
        var timeString = msTime.format("%06d") + ": ";
        System.println(timeString + string);
    }
}