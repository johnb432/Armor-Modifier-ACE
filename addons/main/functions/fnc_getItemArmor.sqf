#include "..\script_component.hpp"
/*
 * Author: Pterolatypus, LinkIsGrim
 * Returns the regular and scaled armor values the given item provides to a particular hitpoint, either from a cache or by reading the item config.
 *
 * Arguments:
 * 0: Item Class <STRING>
 * 1: Hitpoint <STRING>
 *
 * Return Value:
 * Regular and scaled item armor for the given hitpoint <ARRAY of NUMBERs>
 *
 * Example:
 * ["V_PlateCarrier_rgr", "HitChest"] call armor_modifier_ace_main_fnc_getItemArmor
 *
 * Public: No
 */

params ["_item", "_hitpoint"];

GVAR(armorCache) getOrDefaultCall [_this joinString "$", {
    TRACE_2("Cache miss",_item,_hitpoint);
    private _armor = 0;

    if !("" in [_item, _hitpoint]) then {
        private _itemInfo = configFile >> "CfgWeapons" >> _item >> "ItemInfo";
        private _itemType = getNumber (_itemInfo >> "type");

        if (_itemType == TYPE_UNIFORM) then {
            private _unitCfg = configFile >> "CfgVehicles" >> getText (_itemInfo >> "uniformClass");
            _armor = if (_hitpoint == "#structural") then {
                // TODO: I'm not sure if this should be multiplied by the base armor value or not
                getNumber (_unitCfg >> "armorStructural")
            } else {
                getNumber (_unitCfg >> "armor") * (1 max getNumber (_unitCfg >> "HitPoints" >> _hitpoint >> "armor"))
            };
        } else {
            private _condition = format ["getText (_x >> 'hitpointName') == '%1'", _hitpoint];
            private _entry = configProperties [_itemInfo >> "HitpointsProtectionInfo", _condition] param [0, configNull];
            if (!isNull _entry) then {
                _armor = getNumber (_entry >> "armor");
            };
        };
    };

    _armor // return
}, true]
