class ZetaStaff : ZTMyWeapon {
    default {
        ZTMyWeapon.ZT_MELEE true;
        ZTMyWeapon.ZT_MELEECUSTOMDAMAGE true;
        
        ZTMyWeapon.WeaponType "Staff";
        ZTMyWeapon.BaseRating 50;
        ZTMyWeapon.RatingFade 20;
        ZTMyWeapon.Puff "StaffPuff";
        ZetaWeapon.FireInterval 4000000;
        ZetaWeapon.MinAmmo 0;
        ZetaWeapon.AmmoUse 0;
    }

    override int CustomMeleeDamage() {
        return Random(5, 20);       
    }
}