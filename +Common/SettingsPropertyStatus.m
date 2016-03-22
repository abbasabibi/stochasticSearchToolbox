classdef SettingsPropertyStatus
    
    methods
        
        function tf = isProperty(obj)
            tf = ~(obj.UNREGISTERED);
        end
        
        function tf = isInitialized(obj)
            tf = ( (obj == Common.SettingsPropertyStatus.INITIALIZED) || (obj == Common.SettingsPropertyStatus.INITIALIZED_IN_ROOT) );
        end
        
        function tf = isRegistered(obj)
            tf = ( (obj == Common.SettingsPropertyStatus.REGISTERED) || (obj == Common.SettingsPropertyStatus.INITIALIZED_IN_ROOT) );
        end
        
        function tf = isAlias(obj)
            tf = ( (obj == Common.SettingsPropertyStatus.ALIAS) || (obj == Common.SettingsPropertyStatus.ALIAS_IN_ROOT) );
        end
        
        function obj = ofRoot(obj)
            switch(obj)
                case Common.SettingsPropertyStatus.INITIALIZED
                    obj = Common.SettingsPropertyStatus.INITIALIZED_IN_ROOT;
                case Common.SettingsPropertyStatus.REGISTERED
                    obj = Common.SettingsPropertyStatus.REGISTERED_IN_ROOT;
                case Common.SettingsPropertyStatus.ALIAS
                    obj = Common.SettingsPropertyStatus.ALIAS_IN_ROOT;
            end
        end
        
    end
    
    enumeration
        NOT_A_PROPERTY;
        UNREGISTERED;
        INITIALIZED;
        REGISTERED;
        ALIAS;
        INITIALIZED_IN_ROOT;
        REGISTERED_IN_ROOT;
        ALIAS_IN_ROOT;
    end
end

