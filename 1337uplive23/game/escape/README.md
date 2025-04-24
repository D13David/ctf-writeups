# 1337UP LIVE CTF 2023

## Escape

> Your trapped inside a box. Can you escape it and do the reverse to get the flag?
> 
> Author: 0xM4hm0ud
> 
> [`escape.zip`](escape.zip)

Tags: _game_

## Solution
For this challenge we get a `unity game`. Unity uses a natively compiled launcher and gamecode is delivered as `.NET` dll and loaded in a `.NET` environment. The gamecode can, as per default, be typically found in `{ProjectName}_Data\Managed\Assembly-CSharp.dll`. Opening this dll in `dnSpy` gives us code for a vanilla character controller.

When the game is started, the character is placed within a `box`. The player can freely move but cannot leave the box. As the description states, the target should be to leave the box and there are multiple ways to archive this. Collision can be disabled, so that the player can just walk through walls. Another way would be to reset the player position to be outside the box. The solution I chose for this challenge was, to modify the jump code so, that the player could just jump over the walls.

```csharp
if (this._jumpRequested)
{
    if (this.AllowDoubleJump && this._jumpConsumed && !this._doubleJumpConsumed && (this.AllowJumpingWhenSliding ? (!this.Motor.GroundingStatus.FoundAnyGround) : (!this.Motor.GroundingStatus.IsStableOnGround)))
    {
        this.Motor.ForceUnground(0.1f);
        currentVelocity += this.Motor.CharacterUp * this.JumpSpeed - Vector3.Project(currentVelocity, this.Motor.CharacterUp);
        this._jumpRequested = false;
        this._doubleJumpConsumed = true;
        this._jumpedThisFrame = true;
    }
    if (this._canWallJump || (!this._jumpConsumed && ((this.AllowJumpingWhenSliding ? this.Motor.GroundingStatus.FoundAnyGround : this.Motor.GroundingStatus.IsStableOnGround) || this._timeSinceLastAbleToJump <= this.JumpPostGroundingGraceTime)))
    {
        Vector3 a2 = this.Motor.CharacterUp;
        if (this._canWallJump)
        {
            a2 = this._wallJumpNormal;
        }
        else if (this.Motor.GroundingStatus.FoundAnyGround && !this.Motor.GroundingStatus.IsStableOnGround)
        {
            a2 = this.Motor.GroundingStatus.GroundNormal;
        }
        this.Motor.ForceUnground(0.1f);
        currentVelocity += a2 * this.JumpSpeed - Vector3.Project(currentVelocity, this.Motor.CharacterUp);
        this._jumpRequested = false;
        this._jumpConsumed = true;
        this._jumpedThisFrame = true;
    }
    // increase jump height quite drastically... :)
    currentVelocity += Vector3.Project(currentVelocity, this.Motor.CharacterUp) * 20f;
}
```

Recompiling and saving the `module` lets us now easily reach the flag.

![](flag.png)

Flag `INTIGRITI{Y0u_g0t_1t_g00d_J0b!}`