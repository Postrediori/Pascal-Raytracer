{ Raytracer for a scene with a pair of spheres and multiple reflections }

uses
  Crt, Graph;

const
  BgiPath = '.';

function Sign(x: Real): Real;
begin
  if x>0 then
    Sign := 1
  else
    Sign := -1;
end;

var
  gd, gm: Integer;
  N, M: Integer;
  X, Y, Z: Real;
  U, V, W: Real;
  I, E, F, P, D, T, R, G: Real;
  stopReflection: Boolean;
  C: Integer;

begin
  InitGraph(gd, gm, BgiPath);

  for N:=0 to 479 do
    for M:=0 to 639 do
    begin
	  { Rays' origin point }
      X := 0;
      Y := -0.1;
      Z := 3;

      U := (M - 318) / 320;
      V := (240 - N) / 321.34;

      W := 1 / Sqrt(U*U + V*V + 1);
      U := U*W;
      V := V*W;

      { I is the horizontal direction of ray }
	  { based on whether it is in left (U<0) or right (U>0) half of the screen }
      I := Sign(U);
      G := 1;

      { Start the reflection cycle. }
	  { A ray may reflect between one sphere and another multiple times before hitting floor or sky. }
      repeat
        stopReflection := True;
        E := X-I;
        F := Y-I;
        P := U*E + V*F - W*Z;
        D := P*P - E*E - F*F - Z*Z + 1;

        { If ray reflects from a sphere one more time }
        if D>0 then
        begin
          T := -P - Sqrt(D);
          if T>0 then
          begin
            X := X + T*U;
            Y := Y + T*V;
            Z := Z - T*W;
            E := X - I;
            F := Y - I;
            G := Z;
            P := 2*(U*E + V*F - W*G);
            U := U - P*E;
            V := V - P*F;
            W := W + P*G;
			
			{ Invert ray's direction and continue the reflection cycle }
            I := -I;
            stopReflection := False;
          end;
        end;
      until stopReflection;

	  { If Y<0 (V<0) a ray hits the floor }
      if V<0 then
      begin
        P := (Y+2)/V;
		{ Select checkers floor with Black (0) and Red (4) tiles }
        C := (1 And (Round(X - U*P) + Round(Z + W*P))) * 4;
      end else begin
	    { If Y>0 (V>0) a ray hits the sky }
		{ Default sky color is Cyan (11) }
        C := 11;
		{ Condition for using color White (15) to create fancy Cyan-White horizon }
        R := ArcTan(U/W);
        R := 0.2+0.1*Cos(3*R)*Abs(Sin(5*R));
        if Abs(G)<0.35 then
          R := R + 1;
        if V<R then
          C := 15;
      end;

      { Draw current pixel }
      PutPixel(M, N, C);
    end;

  repeat until KeyPressed;
  CloseGraph;
end.