{ Console Ray-tracer }
{ Scene parameters:
  Rays start at (0, 0.23, -2)
  Sphere of radius 1 at the origin
  Floor plane at Y=-2 }

uses
  Crt, Graph;

const
  BgiPath = '.';

var
  gd, gm: Integer;
  U, V: Integer;
  H, J: Real;
  X, Y: Real;
  Z, D, T, P: Real;
  B, C: Integer;

begin
  { Init VGA mode }
  InitGraph(gd, gm, BgiPath);

  { Set parameters of rays origin at (0, 0.23, -2) }
  H := 0.23;
  J := H * H;

  { Enumerate all character position aka 'pixels' }
  for V := 0 TO 480 do
    for U := 0 to 640 do
    begin
      { Convert screen coordinates to plane [-1..1, -0.8..0.6] }
      X := (U - 320) / 320;
      Y := (240 - V) / 300;

      { Calculate ray direction (X,Y,Z) }
      { Here the perspective is provided by calculation of Z
      { with inverset square root function Z=1/Sqrt(L+1) }
      Z := 1 / Sqrt(X * X + Y * Y + 1);
      { Normalize the rest of vector components }
      X := X * Z;
      Y := Y * Z;

      { Check intersection of a sphere with the ray }
      D := 4*Z*Z + J*Y*Y - (3+J);
      B := 0;

      { If the intersection occurs, reflect the ray from the sphere }
      if D>0 then
      begin
        T := 2 * Z - H * Y - Sqrt(D);
        X := T * X;
        Y := T * Y + H;
        Z := T * Z - 2;
        B := 4;
      end;

      { If the ray is headed down, intersect it with the floor plane at Y=-2 }
      { Choose tile colour using (Int(X)+Int(Z)) And 1 }
      if Y<0 then
      begin
        P := (Y + 2) / Y;
        { If the ray hit the sphere add B to the colour for switching }
        { to reflection color }
        C := (Round(Int(X * P) + Int(Z * P)) And 1) + B;
      end else begin
        { If the ray is headed up, set sky color (11, Cyan) }
        C := 11;
        { If it bounced off the sphere, color it randomly white (15) }
        { if the coordinate is near (1,1,-1) for dithering }
        if D>0 then
          if Random>(1-X-Y+Z) then
            C := 15;
      end;

      { Put current 'pixel' to position U,V }
      PutPixel(U, V, C);
    end;

  { Pause after rendering }
  repeat until KeyPressed;
  CloseGraph;
end.