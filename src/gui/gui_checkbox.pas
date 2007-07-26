unit gui_checkbox;

{$mode objfpc}{$H+}

interface

uses
  Classes,
  SysUtils,
  fpgfx,
  gfxbase,
  gfx_widget;
  
type

  TfpgCheckBox = class(TfpgWidget)
  private
    FBackgroundColor: TfpgColor;
    FChecked: boolean;
    FOnChange: TNotifyEvent;
    FText: string;
    FFont: TfpgFont;
    FBoxSize: integer;
    FIsPressed: boolean;
    function    GetFontName: string;
    procedure   SetBackgroundColor(const AValue: TfpgColor);
    procedure   SetChecked(const AValue: boolean);
    procedure   SetFontName(const AValue: string);
    procedure   SetText(const AValue: string);
  protected
    procedure   HandlePaint; override;
    procedure   HandleLMouseDown(x, y: integer; shiftstate: TShiftState); override;
    procedure   HandleLMouseUp(x, y: integer; shiftstate: TShiftState); override;
    procedure   HandleKeyRelease(var keycode: word; var shiftstate: TShiftState; var consumed: boolean); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    property    Font: TfpgFont read FFont;
  published
    property    Checked: boolean read FChecked write SetChecked;
    property    Text: string read FText write SetText;
    property    FontName: string read GetFontName write SetFontName;
    property    BackgroundColor: TfpgColor read FBackgroundColor write SetBackgroundColor;
    property    OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;


function CreateCheckBox(AOwner: TComponent; x, y: TfpgCoord; AText: string): TfpgCheckBox;

implementation

function CreateCheckBox(AOwner: TComponent; x, y: TfpgCoord; AText: string): TfpgCheckBox;
begin
  Result := TfpgCheckBox.Create(AOwner);
  Result.Top    := y;
  Result.Left   := x;
  Result.Text   := AText;
  Result.Width  := Result.Font.TextWidth(Result.Text) + 24;
end;

{ TfpgCheckBox }

procedure TfpgCheckBox.SetChecked(const AValue: boolean);
begin
  if FChecked = AValue then
    Exit; //==>
  FChecked := AValue;
  RePaint;
end;

function TfpgCheckBox.GetFontName: string;
begin
  Result := FFont.FontDesc;
end;

procedure TfpgCheckBox.SetBackgroundColor(const AValue: TfpgColor);
begin
  if FBackgroundColor = AValue then
    Exit; //==>
  FBackgroundColor := AValue;
  RePaint;
end;

procedure TfpgCheckBox.SetFontName(const AValue: string);
begin
  FFont.Free;
  FFont := fpgGetFont(AValue);
  RePaint;
end;

procedure TfpgCheckBox.SetText(const AValue: string);
begin
  if FText = AValue then
    Exit; //==>
  FText := AValue;
  RePaint;
end;

procedure TfpgCheckBox.HandlePaint;
var
  r: TfpgRect;
  ty: integer;
  tx: integer;
  ix: integer;
  img: TfpgImage;
begin
  Canvas.BeginDraw;
  inherited HandlePaint;
  
  Canvas.SetColor(FBackgroundColor);
  Canvas.FillRectangle(0, 0, Width, Height);
  Canvas.SetFont(Font);

  if FFocused then
  begin
    Canvas.SetColor(clText1);
    Canvas.SetLineStyle(1, lsDot);
    Canvas.DrawRectangle(1, 1, Width-1, Height-1);
  end;
  Canvas.SetLineStyle(1, lsSolid);

  r.SetRect(2, (Height div 2) - (FBoxSize div 2), FBoxSize, FBoxSize);
  if r.top < 0 then
    r.top := 0;

  // calculate which image to paint.
  if Enabled then
  begin
    ix := Ord(FChecked);
    if FIsPressed then
      Inc(ix, 2);
  end
  else
    ix := (2 + (Ord(FChecked) * 2)) - Ord(FChecked);

  // paint the check (in this case a X)
  tx := r.right + 8;
  inc(r.left, 2);
  inc(r.top, 1);
  img := fpgImages.GetImage('sys.checkboxes');
  Canvas.DrawImagePart(r.Left, r.Top, img, ix*13, 0, 13, 13);

  ty := (Height div 2) - (Font.Height div 2);
  if ty < 0 then
    ty := 0;
  Canvas.SetTextColor(clText1);
  fpgStyle.DrawString(Canvas, tx, ty, FText, Enabled);

  Canvas.EndDraw;
end;

procedure TfpgCheckBox.HandleLMouseDown(x, y: integer; shiftstate: TShiftState);
begin
  inherited HandleLMouseDown(x, y, shiftstate);
  FIsPressed := True;
  Repaint;
end;

procedure TfpgCheckBox.HandleLMouseUp(x, y: integer; shiftstate: TShiftState);
begin
  inherited HandleLMouseUp(x, y, shiftstate);
  FIsPressed := False;
  Checked := not FChecked;
  if Assigned(FOnChange) then
    FOnChange(self);
end;

procedure TfpgCheckBox.HandleKeyRelease(var keycode: word;
  var shiftstate: TShiftState; var consumed: boolean);
begin
  if (keycode = keySpace) or (keycode = keyReturn) then
  begin
    consumed := True;
    Checked := not FChecked;
    if Assigned(FOnChange) then
      FOnChange(self);
  end;

  if consumed then
    Exit; //==>

  inherited HandleKeyRelease(keycode, shiftstate, consumed);
end;

constructor TfpgCheckBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FText     := 'CheckBox';
  FFont     := fpgGetFont('#Label1');
  FHeight   := FFont.Height + 4;
  FWidth    := 120;

  FBackgroundColor := clWindowBackground;
  FFocusable  := True;
  FBoxSize    := 14;
  FChecked    := False;
  FIsPressed  := False;
  FOnChange   := nil;
end;

destructor TfpgCheckBox.Destroy;
begin
  FFont.Free;
  inherited Destroy;
end;

end.

