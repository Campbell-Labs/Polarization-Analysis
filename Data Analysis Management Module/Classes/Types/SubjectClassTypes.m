classdef SubjectClassTypes
    %SubjectClassTypes
    
    properties
        displayString
    end
    
    enumeration
        Natural     ('Natural')
        Artificial   ('Artificial')
    end
    
    methods
        function enum = SubjectClassTypes(string)
            enum.displayString = string;
        end
    end
    
end

