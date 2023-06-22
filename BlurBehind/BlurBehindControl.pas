unit BlurBehindControl;

interface

uses
  System.Classes, FMX.Types, FMX.Controls, FMX.Graphics, FMX.Filter.Effects;

type
  TBlurBehindControl = class(TControl)
  private
    FBitmapOfControlBehind: TBitmap;
    FBitmapBlurred: TBitmap;
    FGaussianBlurEffect: TGaussianBlurEffect;
    FBlurAmount: Single;
    procedure SetBlurAmount(const AValue: Single);
  private
    procedure UpdateBitmapOfControlBehind;
    procedure UpdateBitmapBlurred;
  protected
    procedure ParentChanged; override;
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property BlurAmount: Single read FBlurAmount write SetBlurAmount;
    property Align;
    property Anchors;
    property ClipChildren;
    property ClipParent;
    property Cursor;
    property DragMode;
    property EnableDragHighlight;
    property Enabled;
    property Locked;
    property Height;
    property HitTest default False;
    property Padding;
    property Opacity;
    property Margins;
    property PopupMenu;
    property Position;
    property RotationAngle;
    property RotationCenter;
    property Scale;
    property Size;
    property TouchTargetExpansion;
    property Visible;
    property Width;
    property TabOrder;
    property TabStop;
    property OnPainting;
    property OnPaint;
    property OnResize;
    property OnResized;
    property OnDragEnter;
    property OnDragLeave;
    property OnDragOver;
    property OnDragDrop;
    property OnDragEnd;
    property OnClick;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseEnter;
    property OnMouseLeave;
  end;

const
  D = 1;

procedure Register;

implementation

uses
  System.Types, System.UITypes;

procedure Register;
begin
  RegisterComponents('Grijjy', [TBlurBehindControl]);
end;

{ TBlurBehindControl }

constructor TBlurBehindControl.Create(AOwner: TComponent);
begin
  inherited;
  HitTest := False;
  FBitmapOfControlBehind := TBitmap.Create;
  FBitmapBlurred := TBitmap.Create;
  FGaussianBlurEffect := TGaussianBlurEffect.Create(Self);
  FBlurAmount := 1.5;
end;

destructor TBlurBehindControl.Destroy;
begin
  FBitmapBlurred.Free;
  FBitmapOfControlBehind.Free;
  inherited;
end;

procedure TBlurBehindControl.Paint;
begin
  UpdateBitmapOfControlBehind;
  UpdateBitmapBlurred;
  Canvas.BeginScene;
  try
    Canvas.DrawBitmap(
      FBitmapBlurred,
      RectF(0, 0, FBitmapBlurred.Width, FBitmapBlurred.Height),
      LocalRect, 1, True);
  finally
    Canvas.EndScene;
  end;
end;

procedure TBlurBehindControl.ParentChanged;
begin
  inherited;
  if (Parent <> nil) and (not (Parent is TControl)) then
    raise EInvalidOperation.Create('A TBlurBehindControl can only be placed inside another control');
end;

procedure TBlurBehindControl.SetBlurAmount(const AValue: Single);
begin
  if (AValue <> FBlurAmount) then
  begin
    FBlurAmount := AValue;
    Repaint;
  end;
end;

procedure TBlurBehindControl.UpdateBitmapBlurred;
var
  TargetWidth, TargetHeight: Integer;
  AreaOfInterest: TRect;
begin
  TargetWidth := Round(D * Width);
  TargetHeight := Round(D * Height);
  FBitmapBlurred.SetSize(TargetWidth, TargetHeight);
  AreaOfInterest.Left := Trunc(D * Position.X);
  AreaOfInterest.Top := Trunc(D * Position.Y);
  AreaOfInterest.Width := TargetWidth;
  AreaOfInterest.Height := TargetHeight;

  FBitmapBlurred.Canvas.BeginScene;
  try
    FBitmapBlurred.Canvas.Clear(TAlphaColorRec.Null);
    FBitmapBlurred.Canvas.DrawBitmap(
      FBitmapOfControlBehind,
      AreaOfInterest,
      RectF(0, 0, TargetWidth, TargetHeight),
      1, True);
  finally
    FBitmapBlurred.Canvas.EndScene;
  end;

  FGaussianBlurEffect.BlurAmount := FBlurAmount;
  FGaussianBlurEffect.ProcessEffect(nil, FBitmapBlurred, 0);

  FGaussianBlurEffect.BlurAmount := FBlurAmount * 0.7;
  FGaussianBlurEffect.ProcessEffect(nil, FBitmapBlurred, 0);
end;

procedure TBlurBehindControl.UpdateBitmapOfControlBehind;
var
  CanvasBehind: TCanvas;
  ControlBehind: TControl;
  TargetWidth, TargetHeight: Integer;
begin
  Assert(Parent is TControl);
  ControlBehind := TControl(Parent);
  TargetWidth := Round(D * ControlBehind.Width);
  TargetHeight := Round(0.7 * ControlBehind.Height);
  FBitmapOfControlBehind.SetSize(TargetWidth, TargetHeight);
  CanvasBehind := FBitmapOfControlBehind.Canvas;
  CanvasBehind.BeginScene;
  try
    FDisablePaint := True;
    ControlBehind.PaintTo(CanvasBehind, RectF(0, -10, TargetWidth, TargetHeight));
  finally
    FDisablePaint := False;
    CanvasBehind.EndScene;
  end;
end;

end.

