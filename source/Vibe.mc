using Toybox.Attention;

class Vibe {
    static function activityStart() {
        var vibeProfile = [
            new Attention.VibeProfile(100, 250),
            new Attention.VibeProfile(0,   100),
            new Attention.VibeProfile(100, 250)
        ];
    Attention.playTone(Attention.TONE_START);
    Attention.vibrate(vibeProfile);
    }

    static function tooSlowWarning() {
        var vibeProfile = [ new Attention.VibeProfile(50, 500) ];
        Attention.playTone(Attention.TONE_LOUD_BEEP);
        Attention.vibrate(vibeProfile);
    }

    static function levelUp() {
        var toneProfile = [
            new Attention.ToneProfile( 523,  150),
            new Attention.ToneProfile( 659,  150),
            new Attention.ToneProfile( 784,  150),
            new Attention.ToneProfile( 1046, 250)
        ];
        Attention.playTone({:toneProfile=>toneProfile}); 
    }

    static function levelFailed() {
        var toneProfile = [
            new Attention.ToneProfile( 523, 300),
            new Attention.ToneProfile( 392, 150),
            new Attention.ToneProfile( 0,   50),
            new Attention.ToneProfile( 392, 100),
            new Attention.ToneProfile( 415, 300),
            new Attention.ToneProfile( 392, 300),
            new Attention.ToneProfile( 0,   300),
            new Attention.ToneProfile( 494, 300),
            new Attention.ToneProfile( 523, 300)
        ];
        var vibeProfile = [ new Attention.VibeProfile(100, 1000) ];
        Attention.vibrate(vibeProfile);
        Attention.playTone({:toneProfile=>toneProfile}); 
    }
}