classdef ArtificialSampleTypes
    %ArtificialSampleTypes
    
    properties
        displayString
        sessionClass
    end
    
    enumeration
        %Artificial Sample
        PureAmyloid ('Pure Amyloid', PureAmyloid.empty)
    end
    
    methods
        function enum = ArtificialSampleTypes(string, class)
            enum.displayString = string;
            enum.sessionClass = class;
        end
    end
    
end