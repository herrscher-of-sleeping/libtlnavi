typedef GeojsonPoint = Array<Int>;

typedef TranslocatorPairFeature = {
    var type:String;
    var properties:{
        var depth1:Int;
        var depth2:Int;
        var label:String;
        var tag:String;
    };
    var geometry:{
        var type:String;
        var coordinates:Array<GeojsonPoint>;
    };
};

typedef TranslocatorsGeojson = {
    var type:String;
    var name:String;
    var features:Array<TranslocatorPairFeature>;
};

typedef LandmarkFeature = {
    var type:String;
    var properties:{
        var type:String;
        var label:String;
        var z:Int;
    };
    var geometry:{
        var type:String;
        var coordinates:GeojsonPoint;
    };
};

typedef LandmarksGeojson = {
    var type:String;
    var name:String;
    var features:Array<LandmarkFeature>;
};