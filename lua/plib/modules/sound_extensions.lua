local table_remove = table.remove
local table_insert = table.insert
local ArgAssert = ArgAssert
local IsValid = IsValid
local ipairs = ipairs

local AudioChannel = FindMetaTable( 'IGModAudioChannel' )
if istable( AudioChannel ) then

    local channels = {}
    hook.Add('Think', 'PLib - Audio Channels', function()
        for num, data in ipairs( channels ) do
            local channel = data.Channel
            if IsValid( channel ) then
                local ent = data.Entity
                if IsValid( ent ) then
                    if ent:IsPlayer() and not ent:Alive() then
                        local ragdoll = ent:GetRagdollEntity()
                        if IsValid( ragdoll ) then
                            channel:SetPos( ragdoll:LocalToWorld( ragdoll:OBBCenter() ) )
                            continue
                        end
                    end

                    channel:SetPos( ent:LocalToWorld( ent:OBBCenter() ) )
                else
                    table_remove( channels, num )
                    channel:Stop()
                    break
                end
            else
                table_remove( channels, num )
                break
            end
        end
    end)

    function AudioChannel:GetEntity()
        for _, data in ipairs( channels ) do
            if (data.Channel == self) then
                return data.Entity
            end
        end
    end

    function AudioChannel:SetEntity( ent )
        if IsValid( ent ) then
            for _, data in ipairs( channels ) do
                if (data.Channel == self) then
                    data.Entity = ent
                    return
                end
            end

            table_insert( channels, {
                ['Channel'] = self,
                ['Entity'] = ent
            } )
        else
            for num, data in ipairs( channels ) do
                if (data.Channel == self) then
                    table_remove( channels, num )
                    break
                end
            end

            self:Stop()
        end
    end

end

if (CLIENT) then

    plib.Require( 'http' )

    local sound_PlayURL = sound.PlayURL
    local cvars_String = cvars.String
    local http_Encode = http.Encode
    local isfunction = isfunction

    function sound.TTS( text, flags, callback )
        ArgAssert( text, 1, 'string' )
        ArgAssert( flags, 2, 'string' )

        sound_PlayURL('http://translate.google.com/translate_tts?tl=' .. cvars_String( 'gmod_language', 'en' ) .. '&ie=UTF-8&q=' .. http_Encode( text ) .. '&client=tw-ob', flags, function( channel )
            if IsValid( channel ) then
                if isfunction( callback ) then
                    callback( channel )
                end

                channel:Play()
            end
        end)
    end

end