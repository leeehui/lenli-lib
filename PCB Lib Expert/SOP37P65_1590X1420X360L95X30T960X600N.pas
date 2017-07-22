Var
    CurrentSCHLib : ISch_Lib;
    CurrentLib : IPCB_Library;

Procedure CreateSMDComponentPad(NewPCBLibComp : IPCB_LibComponent, Name : String, Layer : TLayer, X : Real, Y : Real, OffsetX : Real, OffsetY : Real,
                                TopShape : TShape, TopXSize : Real, TopYSize : Real, Rotation: Real, CRRatio : Real, PMExpansion : Real, SMExpansion : Real,
                                PMFromRules : Boolean, SMFromRules : Boolean);
Var
    NewPad                      : IPCB_Pad2;
    PadCache                    : TPadCache;

Begin
    NewPad := PcbServer.PCBObjectFactory(ePadObject, eNoDimension, eCreate_Default);
    NewPad.HoleSize := MMsToCoord(0);
    NewPad.Layer    := Layer;
    NewPad.TopShape := TopShape;
    if TopShape = eRoundedRectangular then
        NewPad.SetState_StackCRPctOnLayer(eTopLayer, CRRatio);
    NewPad.TopXSize := MMsToCoord(TopXSize);
    NewPad.TopYSize := MMsToCoord(TopYSize);
    NewPad.RotateBy(Rotation);
    NewPad.MoveToXY(MMsToCoord(X), MMsToCoord(Y));
    NewPad.Name := Name;

    Padcache := NewPad.GetState_Cache;
    if (PMExpansion <> 0) or (PMFromRules = False) then
    Begin
        Padcache.PasteMaskExpansionValid   := eCacheManual;
        Padcache.PasteMaskExpansion        := MMsToCoord(PMExpansion);
    End;
    if (SMExpansion <> 0) or (SMFromRules = False) then
    Begin
        Padcache.SolderMaskExpansionValid  := eCacheManual;
        Padcache.SolderMaskExpansion       := MMsToCoord(SMExpansion);
    End;
    NewPad.SetState_Cache              := Padcache;

    NewPCBLibComp.AddPCBObject(NewPad);
    PCBServer.SendMessageToRobots(NewPCBLibComp.I_ObjectAddress,c_Broadcast,PCBM_BoardRegisteration,NewPad.I_ObjectAddress);
End;

Procedure CreateComponentTrack(NewPCBLibComp : IPCB_LibComponent, X1 : Real, Y1 : Real, X2 : Real, Y2 : Real, Layer : TLayer, LineWidth : Real, IsKeepout : Boolean);
Var
    NewTrack                    : IPCB_Track;

Begin
    NewTrack := PcbServer.PCBObjectFactory(eTrackObject,eNoDimension,eCreate_Default);
    NewTrack.X1 := MMsToCoord(X1);
    NewTrack.Y1 := MMsToCoord(Y1);
    NewTrack.X2 := MMsToCoord(X2);
    NewTrack.Y2 := MMsToCoord(Y2);
    NewTrack.Layer := Layer;
    NewTrack.Width := MMsToCoord(LineWidth);
    NewTrack.IsKeepout := IsKeepout;
    NewPCBLibComp.AddPCBObject(NewTrack);
    PCBServer.SendMessageToRobots(NewPCBLibComp.I_ObjectAddress,c_Broadcast,PCBM_BoardRegisteration,NewTrack.I_ObjectAddress);
End;

Procedure CreateComponentArc(NewPCBLibComp : IPCB_LibComponent, CenterX : Real, CenterY : Real, Radius : Real, StartAngle : Real, EndAngle : Real, Layer : TLayer, LineWidth : Real, IsKeepout : Boolean);
Var
    NewArc                      : IPCB_Arc;

Begin
    NewArc := PCBServer.PCBObjectFactory(eArcObject,eNoDimension,eCreate_Default);
    NewArc.XCenter := MMsToCoord(CenterX);
    NewArc.YCenter := MMsToCoord(CenterY);
    NewArc.Radius := MMsToCoord(Radius);
    NewArc.StartAngle := StartAngle;
    NewArc.EndAngle := EndAngle;
    NewArc.Layer := Layer;
    NewArc.LineWidth := MMsToCoord(LineWidth);
    NewArc.IsKeepout := IsKeepout;
    NewPCBLibComp.AddPCBObject(NewArc);
    PCBServer.SendMessageToRobots(NewPCBLibComp.I_ObjectAddress,c_Broadcast,PCBM_BoardRegisteration,NewArc.I_ObjectAddress);
End;

Function ReadStringFromIniFile(Section: String, Name: String, FilePath: String, IfEmpty: String) : String;
Var
    IniFile                     : TIniFile;

Begin
    result := IfEmpty;
    If FileExists(FilePath) Then
    Begin
        Try
            IniFile := TIniFile.Create(FilePath);

            Result := IniFile.ReadString(Section, Name, IfEmpty);
        Finally
            Inifile.Free;
        End;
    End;
End;

Procedure EnableMechanicalLayers(Zero : Integer);
Var
    Board                       : IPCB_Board;
    MajorADVersion              : Integer;

Begin
    Board := PCBServer.GetCurrentPCBBoard;

    MajorADVersion := StrToInt(Copy((ReadStringFromIniFile('Preference Location','Build',SpecialFolder_AltiumSystem+'\PrefFolder.ini','14')),0,2));

    If MajorADVersion >= 14 Then
    Begin
    End;

    If MajorADVersion < 14 Then
    Begin
    End;
End;

Procedure CreateComponentSOP37P65_1590X1420X360L95X30T960X600N(Zero : integer);
Var
    NewPCBLibComp               : IPCB_LibComponent;
    NewPad                      : IPCB_Pad2;
    NewRegion                   : IPCB_Region;
    NewContour                  : IPCB_Contour;
    STEPmodel                   : IPCB_ComponentBody;
    Model                       : IPCB_Model;
    TextObj                     : IPCB_Text;

Begin
    Try
        PCBServer.PreProcess;

        EnableMechanicalLayers(0);

        NewPCBLibComp := PCBServer.CreatePCBLibComp;
        NewPcbLibComp.Name := 'SOP37P65_1590X1420X360L95X30T960X600N';
        NewPCBLibComp.Description := 'Small Outline Pkg (SOP with Tab), 0.65 mm pitch; 36 pin, 15.90 mm L X 11.00 mm W X 3.60 mm H body';
        NewPCBLibComp.Height := MMsToCoord(3.6);

        // Create text object for .Designator
        TextObj := PCBServer.PCBObjectFactory(eTextObject, eNoDimension, eCreate_Default);
        TextObj.UseTTFonts := True;
        TextObj.Layer := eMechanical16;
        TextObj.Text := '.Designator';
        TextObj.Size := MMsToCoord(1.2);
        NewPCBLibComp.AddPCBObject(TextObj);
        PCBServer.SendMessageToRobots(NewPCBLibComp.I_ObjectAddress,c_Broadcast,PCBM_BoardRegisteration,TextObj.I_ObjectAddress);

        CreateSMDComponentPad(NewPCBLibComp, '1', eTopLayer, -5.525, -6.56, 0, 0, eRoundedRectangular, 1.79, 0.46, 270, 52.17, 0, 0, True, True);
        CreateSMDComponentPad(NewPCBLibComp, '2', eTopLayer, -4.875, -6.56, 0, 0, eRoundedRectangular, 1.79, 0.46, 270, 52.17, 0, 0, True, True);
        CreateSMDComponentPad(NewPCBLibComp, '3', eTopLayer, -4.225, -6.56, 0, 0, eRoundedRectangular, 1.79, 0.46, 270, 52.17, 0, 0, True, True);
        CreateSMDComponentPad(NewPCBLibComp, '4', eTopLayer, -3.575, -6.56, 0, 0, eRoundedRectangular, 1.79, 0.46, 270, 52.17, 0, 0, True, True);
        CreateSMDComponentPad(NewPCBLibComp, '5', eTopLayer, -2.925, -6.56, 0, 0, eRoundedRectangular, 1.79, 0.46, 270, 52.17, 0, 0, True, True);
        CreateSMDComponentPad(NewPCBLibComp, '6', eTopLayer, -2.275, -6.56, 0, 0, eRoundedRectangular, 1.79, 0.46, 270, 52.17, 0, 0, True, True);
        CreateSMDComponentPad(NewPCBLibComp, '7', eTopLayer, -1.625, -6.56, 0, 0, eRoundedRectangular, 1.79, 0.46, 270, 52.17, 0, 0, True, True);
        CreateSMDComponentPad(NewPCBLibComp, '8', eTopLayer, -0.975, -6.56, 0, 0, eRoundedRectangular, 1.79, 0.46, 270, 52.17, 0, 0, True, True);
        CreateSMDComponentPad(NewPCBLibComp, '9', eTopLayer, -0.325, -6.56, 0, 0, eRoundedRectangular, 1.79, 0.46, 270, 52.17, 0, 0, True, True);
        CreateSMDComponentPad(NewPCBLibComp, '10', eTopLayer, 0.325, -6.56, 0, 0, eRoundedRectangular, 1.79, 0.46, 270, 52.17, 0, 0, True, True);
        CreateSMDComponentPad(NewPCBLibComp, '11', eTopLayer, 0.975, -6.56, 0, 0, eRoundedRectangular, 1.79, 0.46, 270, 52.17, 0, 0, True, True);
        CreateSMDComponentPad(NewPCBLibComp, '12', eTopLayer, 1.625, -6.56, 0, 0, eRoundedRectangular, 1.79, 0.46, 270, 52.17, 0, 0, True, True);
        CreateSMDComponentPad(NewPCBLibComp, '13', eTopLayer, 2.275, -6.56, 0, 0, eRoundedRectangular, 1.79, 0.46, 270, 52.17, 0, 0, True, True);
        CreateSMDComponentPad(NewPCBLibComp, '14', eTopLayer, 2.925, -6.56, 0, 0, eRoundedRectangular, 1.79, 0.46, 270, 52.17, 0, 0, True, True);
        CreateSMDComponentPad(NewPCBLibComp, '15', eTopLayer, 3.575, -6.56, 0, 0, eRoundedRectangular, 1.79, 0.46, 270, 52.17, 0, 0, True, True);
        CreateSMDComponentPad(NewPCBLibComp, '16', eTopLayer, 4.225, -6.56, 0, 0, eRoundedRectangular, 1.79, 0.46, 270, 52.17, 0, 0, True, True);
        CreateSMDComponentPad(NewPCBLibComp, '17', eTopLayer, 4.875, -6.56, 0, 0, eRoundedRectangular, 1.79, 0.46, 270, 52.17, 0, 0, True, True);
        CreateSMDComponentPad(NewPCBLibComp, '18', eTopLayer, 5.525, -6.56, 0, 0, eRoundedRectangular, 1.79, 0.46, 270, 52.17, 0, 0, True, True);
        CreateSMDComponentPad(NewPCBLibComp, '19', eTopLayer, 5.525, 6.56, 0, 0, eRoundedRectangular, 1.79, 0.46, 90, 52.17, 0, 0, True, True);
        CreateSMDComponentPad(NewPCBLibComp, '20', eTopLayer, 4.875, 6.56, 0, 0, eRoundedRectangular, 1.79, 0.46, 90, 52.17, 0, 0, True, True);
        CreateSMDComponentPad(NewPCBLibComp, '21', eTopLayer, 4.225, 6.56, 0, 0, eRoundedRectangular, 1.79, 0.46, 90, 52.17, 0, 0, True, True);
        CreateSMDComponentPad(NewPCBLibComp, '22', eTopLayer, 3.575, 6.56, 0, 0, eRoundedRectangular, 1.79, 0.46, 90, 52.17, 0, 0, True, True);
        CreateSMDComponentPad(NewPCBLibComp, '23', eTopLayer, 2.925, 6.56, 0, 0, eRoundedRectangular, 1.79, 0.46, 90, 52.17, 0, 0, True, True);
        CreateSMDComponentPad(NewPCBLibComp, '24', eTopLayer, 2.275, 6.56, 0, 0, eRoundedRectangular, 1.79, 0.46, 90, 52.17, 0, 0, True, True);
        CreateSMDComponentPad(NewPCBLibComp, '25', eTopLayer, 1.625, 6.56, 0, 0, eRoundedRectangular, 1.79, 0.46, 90, 52.17, 0, 0, True, True);
        CreateSMDComponentPad(NewPCBLibComp, '26', eTopLayer, 0.975, 6.56, 0, 0, eRoundedRectangular, 1.79, 0.46, 90, 52.17, 0, 0, True, True);
        CreateSMDComponentPad(NewPCBLibComp, '27', eTopLayer, 0.325, 6.56, 0, 0, eRoundedRectangular, 1.79, 0.46, 90, 52.17, 0, 0, True, True);
        CreateSMDComponentPad(NewPCBLibComp, '28', eTopLayer, -0.325, 6.56, 0, 0, eRoundedRectangular, 1.79, 0.46, 90, 52.17, 0, 0, True, True);
        CreateSMDComponentPad(NewPCBLibComp, '29', eTopLayer, -0.975, 6.56, 0, 0, eRoundedRectangular, 1.79, 0.46, 90, 52.17, 0, 0, True, True);
        CreateSMDComponentPad(NewPCBLibComp, '30', eTopLayer, -1.625, 6.56, 0, 0, eRoundedRectangular, 1.79, 0.46, 90, 52.17, 0, 0, True, True);
        CreateSMDComponentPad(NewPCBLibComp, '31', eTopLayer, -2.275, 6.56, 0, 0, eRoundedRectangular, 1.79, 0.46, 90, 52.17, 0, 0, True, True);
        CreateSMDComponentPad(NewPCBLibComp, '32', eTopLayer, -2.925, 6.56, 0, 0, eRoundedRectangular, 1.79, 0.46, 90, 52.17, 0, 0, True, True);
        CreateSMDComponentPad(NewPCBLibComp, '33', eTopLayer, -3.575, 6.56, 0, 0, eRoundedRectangular, 1.79, 0.46, 90, 52.17, 0, 0, True, True);
        CreateSMDComponentPad(NewPCBLibComp, '34', eTopLayer, -4.225, 6.56, 0, 0, eRoundedRectangular, 1.79, 0.46, 90, 52.17, 0, 0, True, True);
        CreateSMDComponentPad(NewPCBLibComp, '35', eTopLayer, -4.875, 6.56, 0, 0, eRoundedRectangular, 1.79, 0.46, 90, 52.17, 0, 0, True, True);
        CreateSMDComponentPad(NewPCBLibComp, '36', eTopLayer, -5.525, 6.56, 0, 0, eRoundedRectangular, 1.79, 0.46, 90, 52.17, 0, 0, True, True);
        CreateSMDComponentPad(NewPCBLibComp, '37', eTopLayer, 0, 0, 0, 0, eRectangular, 6, 7.6, 90, 0, -7.6, 0, True, False);

        NewRegion := PCBServer.PCBObjectFactory(eRegionObject, eNoDimension, eCreate_Default);
        NewContour := PCBServer.PCBContourFactory;
        NewContour.AddPoint(MMsToCoord(4.8), MMsToCoord(0));
        NewContour.AddPoint(MMsToCoord(4.8), MMsToCoord(-2.5));
        NewContour.AddPoint(MMsToCoord(4.7938), MMsToCoord(-2.5782));
        NewContour.AddPoint(MMsToCoord(4.7755), MMsToCoord(-2.6545));
        NewContour.AddPoint(MMsToCoord(4.7455), MMsToCoord(-2.727));
        NewContour.AddPoint(MMsToCoord(4.7045), MMsToCoord(-2.7939));
        NewContour.AddPoint(MMsToCoord(4.6536), MMsToCoord(-2.8536));
        NewContour.AddPoint(MMsToCoord(4.5939), MMsToCoord(-2.9045));
        NewContour.AddPoint(MMsToCoord(4.527), MMsToCoord(-2.9455));
        NewContour.AddPoint(MMsToCoord(4.4545), MMsToCoord(-2.9755));
        NewContour.AddPoint(MMsToCoord(4.3782), MMsToCoord(-2.9938));
        NewContour.AddPoint(MMsToCoord(-3.8), MMsToCoord(-3));
        NewContour.AddPoint(MMsToCoord(-4.8), MMsToCoord(-2));
        NewContour.AddPoint(MMsToCoord(-4.8), MMsToCoord(2.5));
        NewContour.AddPoint(MMsToCoord(-4.7938), MMsToCoord(2.5782));
        NewContour.AddPoint(MMsToCoord(-4.7755), MMsToCoord(2.6545));
        NewContour.AddPoint(MMsToCoord(-4.7455), MMsToCoord(2.727));
        NewContour.AddPoint(MMsToCoord(-4.7045), MMsToCoord(2.7939));
        NewContour.AddPoint(MMsToCoord(-4.6536), MMsToCoord(2.8536));
        NewContour.AddPoint(MMsToCoord(-4.5939), MMsToCoord(2.9045));
        NewContour.AddPoint(MMsToCoord(-4.527), MMsToCoord(2.9455));
        NewContour.AddPoint(MMsToCoord(-4.4545), MMsToCoord(2.9755));
        NewContour.AddPoint(MMsToCoord(-4.3782), MMsToCoord(2.9938));
        NewContour.AddPoint(MMsToCoord(4.3), MMsToCoord(3));
        NewContour.AddPoint(MMsToCoord(4.3782), MMsToCoord(2.9938));
        NewContour.AddPoint(MMsToCoord(4.4545), MMsToCoord(2.9755));
        NewContour.AddPoint(MMsToCoord(4.527), MMsToCoord(2.9455));
        NewContour.AddPoint(MMsToCoord(4.5939), MMsToCoord(2.9045));
        NewContour.AddPoint(MMsToCoord(4.6536), MMsToCoord(2.8536));
        NewContour.AddPoint(MMsToCoord(4.7045), MMsToCoord(2.7939));
        NewContour.AddPoint(MMsToCoord(4.7455), MMsToCoord(2.727));
        NewContour.AddPoint(MMsToCoord(4.7755), MMsToCoord(2.6545));
        NewContour.AddPoint(MMsToCoord(4.7938), MMsToCoord(2.5782));
        NewContour.AddPoint(MMsToCoord(4.8), MMsToCoord(2.5));
        NewContour.AddPoint(MMsToCoord(4.8), MMsToCoord(0));
        NewRegion.SetOutlineContour(NewContour);
        NewRegion.Layer := eTopLayer;
        NewPCBLibComp.AddPCBObject(NewRegion);

        NewRegion := PCBServer.PCBObjectFactory(eRegionObject, eNoDimension, eCreate_Default);
        NewContour := PCBServer.PCBContourFactory;
        NewContour.AddPoint(MMsToCoord(4.8), MMsToCoord(0));
        NewContour.AddPoint(MMsToCoord(4.8), MMsToCoord(-2.5));
        NewContour.AddPoint(MMsToCoord(4.7938), MMsToCoord(-2.5782));
        NewContour.AddPoint(MMsToCoord(4.7755), MMsToCoord(-2.6545));
        NewContour.AddPoint(MMsToCoord(4.7455), MMsToCoord(-2.727));
        NewContour.AddPoint(MMsToCoord(4.7045), MMsToCoord(-2.7939));
        NewContour.AddPoint(MMsToCoord(4.6536), MMsToCoord(-2.8536));
        NewContour.AddPoint(MMsToCoord(4.5939), MMsToCoord(-2.9045));
        NewContour.AddPoint(MMsToCoord(4.527), MMsToCoord(-2.9455));
        NewContour.AddPoint(MMsToCoord(4.4545), MMsToCoord(-2.9755));
        NewContour.AddPoint(MMsToCoord(4.3782), MMsToCoord(-2.9938));
        NewContour.AddPoint(MMsToCoord(-3.8), MMsToCoord(-3));
        NewContour.AddPoint(MMsToCoord(-4.8), MMsToCoord(-2));
        NewContour.AddPoint(MMsToCoord(-4.8), MMsToCoord(2.5));
        NewContour.AddPoint(MMsToCoord(-4.7938), MMsToCoord(2.5782));
        NewContour.AddPoint(MMsToCoord(-4.7755), MMsToCoord(2.6545));
        NewContour.AddPoint(MMsToCoord(-4.7455), MMsToCoord(2.727));
        NewContour.AddPoint(MMsToCoord(-4.7045), MMsToCoord(2.7939));
        NewContour.AddPoint(MMsToCoord(-4.6536), MMsToCoord(2.8536));
        NewContour.AddPoint(MMsToCoord(-4.5939), MMsToCoord(2.9045));
        NewContour.AddPoint(MMsToCoord(-4.527), MMsToCoord(2.9455));
        NewContour.AddPoint(MMsToCoord(-4.4545), MMsToCoord(2.9755));
        NewContour.AddPoint(MMsToCoord(-4.3782), MMsToCoord(2.9938));
        NewContour.AddPoint(MMsToCoord(4.3), MMsToCoord(3));
        NewContour.AddPoint(MMsToCoord(4.3782), MMsToCoord(2.9938));
        NewContour.AddPoint(MMsToCoord(4.4545), MMsToCoord(2.9755));
        NewContour.AddPoint(MMsToCoord(4.527), MMsToCoord(2.9455));
        NewContour.AddPoint(MMsToCoord(4.5939), MMsToCoord(2.9045));
        NewContour.AddPoint(MMsToCoord(4.6536), MMsToCoord(2.8536));
        NewContour.AddPoint(MMsToCoord(4.7045), MMsToCoord(2.7939));
        NewContour.AddPoint(MMsToCoord(4.7455), MMsToCoord(2.727));
        NewContour.AddPoint(MMsToCoord(4.7755), MMsToCoord(2.6545));
        NewContour.AddPoint(MMsToCoord(4.7938), MMsToCoord(2.5782));
        NewContour.AddPoint(MMsToCoord(4.8), MMsToCoord(2.5));
        NewContour.AddPoint(MMsToCoord(4.8), MMsToCoord(0));
        NewRegion.SetOutlineContour(NewContour);
        NewRegion.Layer := eTopSolder;
        NewPCBLibComp.AddPCBObject(NewRegion);


        NewRegion := PCBServer.PCBObjectFactory(eRegionObject, eNoDimension, eCreate_Default);
        NewContour := PCBServer.PCBContourFactory;
        NewContour.AddPoint(MMsToCoord(4.6188), MMsToCoord(-2.6445));
        NewContour.AddPoint(MMsToCoord(3.38), MMsToCoord(-2.6445));
        NewContour.AddPoint(MMsToCoord(3.38), MMsToCoord(-1.355));
        NewContour.AddPoint(MMsToCoord(4.6188), MMsToCoord(-1.355));
        NewContour.AddPoint(MMsToCoord(4.6188), MMsToCoord(-2.6445));
        NewRegion.SetOutlineContour(NewContour);
        NewRegion.Layer := eTopPaste;
        NewPCBLibComp.AddPCBObject(NewRegion);

        NewRegion := PCBServer.PCBObjectFactory(eRegionObject, eNoDimension, eCreate_Default);
        NewContour := PCBServer.PCBContourFactory;
        NewContour.AddPoint(MMsToCoord(4.62), MMsToCoord(-0.645));
        NewContour.AddPoint(MMsToCoord(3.38), MMsToCoord(-0.645));
        NewContour.AddPoint(MMsToCoord(3.38), MMsToCoord(0.645));
        NewContour.AddPoint(MMsToCoord(4.62), MMsToCoord(0.645));
        NewContour.AddPoint(MMsToCoord(4.62), MMsToCoord(-0.645));
        NewRegion.SetOutlineContour(NewContour);
        NewRegion.Layer := eTopPaste;
        NewPCBLibComp.AddPCBObject(NewRegion);

        NewRegion := PCBServer.PCBObjectFactory(eRegionObject, eNoDimension, eCreate_Default);
        NewContour := PCBServer.PCBContourFactory;
        NewContour.AddPoint(MMsToCoord(4.6188), MMsToCoord(2.6442));
        NewContour.AddPoint(MMsToCoord(3.38), MMsToCoord(2.6442));
        NewContour.AddPoint(MMsToCoord(3.38), MMsToCoord(2.6447));
        NewContour.AddPoint(MMsToCoord(4.6188), MMsToCoord(2.6447));
        NewContour.AddPoint(MMsToCoord(4.6188), MMsToCoord(2.6442));
        NewRegion.SetOutlineContour(NewContour);
        NewRegion.Layer := eTopPaste;
        NewPCBLibComp.AddPCBObject(NewRegion);

        NewRegion := PCBServer.PCBObjectFactory(eRegionObject, eNoDimension, eCreate_Default);
        NewContour := PCBServer.PCBContourFactory;
        NewContour.AddPoint(MMsToCoord(3.02), MMsToCoord(-2.645));
        NewContour.AddPoint(MMsToCoord(1.78), MMsToCoord(-2.645));
        NewContour.AddPoint(MMsToCoord(1.78), MMsToCoord(-1.355));
        NewContour.AddPoint(MMsToCoord(3.02), MMsToCoord(-1.355));
        NewContour.AddPoint(MMsToCoord(3.02), MMsToCoord(-2.645));
        NewRegion.SetOutlineContour(NewContour);
        NewRegion.Layer := eTopPaste;
        NewPCBLibComp.AddPCBObject(NewRegion);

        NewRegion := PCBServer.PCBObjectFactory(eRegionObject, eNoDimension, eCreate_Default);
        NewContour := PCBServer.PCBContourFactory;
        NewContour.AddPoint(MMsToCoord(3.02), MMsToCoord(-0.645));
        NewContour.AddPoint(MMsToCoord(1.78), MMsToCoord(-0.645));
        NewContour.AddPoint(MMsToCoord(1.78), MMsToCoord(0.645));
        NewContour.AddPoint(MMsToCoord(3.02), MMsToCoord(0.645));
        NewContour.AddPoint(MMsToCoord(3.02), MMsToCoord(-0.645));
        NewRegion.SetOutlineContour(NewContour);
        NewRegion.Layer := eTopPaste;
        NewPCBLibComp.AddPCBObject(NewRegion);

        NewRegion := PCBServer.PCBObjectFactory(eRegionObject, eNoDimension, eCreate_Default);
        NewContour := PCBServer.PCBContourFactory;
        NewContour.AddPoint(MMsToCoord(3.02), MMsToCoord(1.355));
        NewContour.AddPoint(MMsToCoord(1.78), MMsToCoord(1.355));
        NewContour.AddPoint(MMsToCoord(1.78), MMsToCoord(2.645));
        NewContour.AddPoint(MMsToCoord(3.02), MMsToCoord(2.645));
        NewContour.AddPoint(MMsToCoord(3.02), MMsToCoord(1.355));
        NewRegion.SetOutlineContour(NewContour);
        NewRegion.Layer := eTopPaste;
        NewPCBLibComp.AddPCBObject(NewRegion);

        NewRegion := PCBServer.PCBObjectFactory(eRegionObject, eNoDimension, eCreate_Default);
        NewContour := PCBServer.PCBContourFactory;
        NewContour.AddPoint(MMsToCoord(1.42), MMsToCoord(-2.645));
        NewContour.AddPoint(MMsToCoord(0.18), MMsToCoord(-2.645));
        NewContour.AddPoint(MMsToCoord(0.18), MMsToCoord(-1.355));
        NewContour.AddPoint(MMsToCoord(1.42), MMsToCoord(-1.355));
        NewContour.AddPoint(MMsToCoord(1.42), MMsToCoord(-2.645));
        NewRegion.SetOutlineContour(NewContour);
        NewRegion.Layer := eTopPaste;
        NewPCBLibComp.AddPCBObject(NewRegion);

        NewRegion := PCBServer.PCBObjectFactory(eRegionObject, eNoDimension, eCreate_Default);
        NewContour := PCBServer.PCBContourFactory;
        NewContour.AddPoint(MMsToCoord(1.42), MMsToCoord(-0.645));
        NewContour.AddPoint(MMsToCoord(0.18), MMsToCoord(-0.645));
        NewContour.AddPoint(MMsToCoord(0.18), MMsToCoord(0.645));
        NewContour.AddPoint(MMsToCoord(1.42), MMsToCoord(0.645));
        NewContour.AddPoint(MMsToCoord(1.42), MMsToCoord(-0.645));
        NewRegion.SetOutlineContour(NewContour);
        NewRegion.Layer := eTopPaste;
        NewPCBLibComp.AddPCBObject(NewRegion);

        NewRegion := PCBServer.PCBObjectFactory(eRegionObject, eNoDimension, eCreate_Default);
        NewContour := PCBServer.PCBContourFactory;
        NewContour.AddPoint(MMsToCoord(1.42), MMsToCoord(1.355));
        NewContour.AddPoint(MMsToCoord(0.18), MMsToCoord(1.355));
        NewContour.AddPoint(MMsToCoord(0.18), MMsToCoord(2.645));
        NewContour.AddPoint(MMsToCoord(1.42), MMsToCoord(2.645));
        NewContour.AddPoint(MMsToCoord(1.42), MMsToCoord(1.355));
        NewRegion.SetOutlineContour(NewContour);
        NewRegion.Layer := eTopPaste;
        NewPCBLibComp.AddPCBObject(NewRegion);

        NewRegion := PCBServer.PCBObjectFactory(eRegionObject, eNoDimension, eCreate_Default);
        NewContour := PCBServer.PCBContourFactory;
        NewContour.AddPoint(MMsToCoord(-0.18), MMsToCoord(-2.645));
        NewContour.AddPoint(MMsToCoord(-1.42), MMsToCoord(-2.645));
        NewContour.AddPoint(MMsToCoord(-1.42), MMsToCoord(-1.355));
        NewContour.AddPoint(MMsToCoord(-0.18), MMsToCoord(-1.355));
        NewContour.AddPoint(MMsToCoord(-0.18), MMsToCoord(-2.645));
        NewRegion.SetOutlineContour(NewContour);
        NewRegion.Layer := eTopPaste;
        NewPCBLibComp.AddPCBObject(NewRegion);

        NewRegion := PCBServer.PCBObjectFactory(eRegionObject, eNoDimension, eCreate_Default);
        NewContour := PCBServer.PCBContourFactory;
        NewContour.AddPoint(MMsToCoord(-0.18), MMsToCoord(-0.645));
        NewContour.AddPoint(MMsToCoord(-1.42), MMsToCoord(-0.645));
        NewContour.AddPoint(MMsToCoord(-1.42), MMsToCoord(0.645));
        NewContour.AddPoint(MMsToCoord(-0.18), MMsToCoord(0.645));
        NewContour.AddPoint(MMsToCoord(-0.18), MMsToCoord(-0.645));
        NewRegion.SetOutlineContour(NewContour);
        NewRegion.Layer := eTopPaste;
        NewPCBLibComp.AddPCBObject(NewRegion);

        NewRegion := PCBServer.PCBObjectFactory(eRegionObject, eNoDimension, eCreate_Default);
        NewContour := PCBServer.PCBContourFactory;
        NewContour.AddPoint(MMsToCoord(-0.18), MMsToCoord(1.355));
        NewContour.AddPoint(MMsToCoord(-1.42), MMsToCoord(1.355));
        NewContour.AddPoint(MMsToCoord(-1.42), MMsToCoord(2.645));
        NewContour.AddPoint(MMsToCoord(-0.18), MMsToCoord(2.645));
        NewContour.AddPoint(MMsToCoord(-0.18), MMsToCoord(1.355));
        NewRegion.SetOutlineContour(NewContour);
        NewRegion.Layer := eTopPaste;
        NewPCBLibComp.AddPCBObject(NewRegion);

        NewRegion := PCBServer.PCBObjectFactory(eRegionObject, eNoDimension, eCreate_Default);
        NewContour := PCBServer.PCBContourFactory;
        NewContour.AddPoint(MMsToCoord(-1.78), MMsToCoord(-2.645));
        NewContour.AddPoint(MMsToCoord(-3.02), MMsToCoord(-2.645));
        NewContour.AddPoint(MMsToCoord(-3.02), MMsToCoord(-1.355));
        NewContour.AddPoint(MMsToCoord(-1.78), MMsToCoord(-1.355));
        NewContour.AddPoint(MMsToCoord(-1.78), MMsToCoord(-2.645));
        NewRegion.SetOutlineContour(NewContour);
        NewRegion.Layer := eTopPaste;
        NewPCBLibComp.AddPCBObject(NewRegion);

        NewRegion := PCBServer.PCBObjectFactory(eRegionObject, eNoDimension, eCreate_Default);
        NewContour := PCBServer.PCBContourFactory;
        NewContour.AddPoint(MMsToCoord(-1.78), MMsToCoord(-0.645));
        NewContour.AddPoint(MMsToCoord(-3.02), MMsToCoord(-0.645));
        NewContour.AddPoint(MMsToCoord(-3.02), MMsToCoord(0.645));
        NewContour.AddPoint(MMsToCoord(-1.78), MMsToCoord(0.645));
        NewContour.AddPoint(MMsToCoord(-1.78), MMsToCoord(-0.645));
        NewRegion.SetOutlineContour(NewContour);
        NewRegion.Layer := eTopPaste;
        NewPCBLibComp.AddPCBObject(NewRegion);

        NewRegion := PCBServer.PCBObjectFactory(eRegionObject, eNoDimension, eCreate_Default);
        NewContour := PCBServer.PCBContourFactory;
        NewContour.AddPoint(MMsToCoord(-1.78), MMsToCoord(1.355));
        NewContour.AddPoint(MMsToCoord(-3.02), MMsToCoord(1.355));
        NewContour.AddPoint(MMsToCoord(-3.02), MMsToCoord(2.645));
        NewContour.AddPoint(MMsToCoord(-1.78), MMsToCoord(2.645));
        NewContour.AddPoint(MMsToCoord(-1.78), MMsToCoord(1.355));
        NewRegion.SetOutlineContour(NewContour);
        NewRegion.Layer := eTopPaste;
        NewPCBLibComp.AddPCBObject(NewRegion);

        NewRegion := PCBServer.PCBObjectFactory(eRegionObject, eNoDimension, eCreate_Default);
        NewContour := PCBServer.PCBContourFactory;
        NewContour.AddPoint(MMsToCoord(-3.38), MMsToCoord(-2.4403));
        NewContour.AddPoint(MMsToCoord(-4.3597), MMsToCoord(-2.4403));
        NewContour.AddPoint(MMsToCoord(-4.3597), MMsToCoord(-1.355));
        NewContour.AddPoint(MMsToCoord(-3.38), MMsToCoord(-1.355));
        NewContour.AddPoint(MMsToCoord(-3.38), MMsToCoord(-2.4403));
        NewRegion.SetOutlineContour(NewContour);
        NewRegion.Layer := eTopPaste;
        NewPCBLibComp.AddPCBObject(NewRegion);

        NewRegion := PCBServer.PCBObjectFactory(eRegionObject, eNoDimension, eCreate_Default);
        NewContour := PCBServer.PCBContourFactory;
        NewContour.AddPoint(MMsToCoord(-3.38), MMsToCoord(-0.645));
        NewContour.AddPoint(MMsToCoord(-4.62), MMsToCoord(-0.645));
        NewContour.AddPoint(MMsToCoord(-4.62), MMsToCoord(0.645));
        NewContour.AddPoint(MMsToCoord(-3.38), MMsToCoord(0.645));
        NewContour.AddPoint(MMsToCoord(-3.38), MMsToCoord(-0.645));
        NewRegion.SetOutlineContour(NewContour);
        NewRegion.Layer := eTopPaste;
        NewPCBLibComp.AddPCBObject(NewRegion);

        NewRegion := PCBServer.PCBObjectFactory(eRegionObject, eNoDimension, eCreate_Default);
        NewContour := PCBServer.PCBContourFactory;
        NewContour.AddPoint(MMsToCoord(-3.38), MMsToCoord(1.355));
        NewContour.AddPoint(MMsToCoord(-4.6188), MMsToCoord(1.355));
        NewContour.AddPoint(MMsToCoord(-4.6188), MMsToCoord(2.6445));
        NewContour.AddPoint(MMsToCoord(-3.38), MMsToCoord(2.6445));
        NewContour.AddPoint(MMsToCoord(-3.38), MMsToCoord(1.355));
        NewRegion.SetOutlineContour(NewContour);
        NewRegion.Layer := eTopPaste;
        NewPCBLibComp.AddPCBObject(NewRegion);

        CreateComponentTrack(NewPCBLibComp, -5.675, -6.15, -5.375, -6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -5.375, -6.15, -5.375, -7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -5.375, -7.1, -5.675, -7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -5.675, -7.1, -5.675, -6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -5.025, -6.15, -4.725, -6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -4.725, -6.15, -4.725, -7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -4.725, -7.1, -5.025, -7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -5.025, -7.1, -5.025, -6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -4.375, -6.15, -4.075, -6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -4.075, -6.15, -4.075, -7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -4.075, -7.1, -4.375, -7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -4.375, -7.1, -4.375, -6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -3.725, -6.15, -3.425, -6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -3.425, -6.15, -3.425, -7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -3.425, -7.1, -3.725, -7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -3.725, -7.1, -3.725, -6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -3.075, -6.15, -2.775, -6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -2.775, -6.15, -2.775, -7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -2.775, -7.1, -3.075, -7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -3.075, -7.1, -3.075, -6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -2.425, -6.15, -2.125, -6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -2.125, -6.15, -2.125, -7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -2.125, -7.1, -2.425, -7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -2.425, -7.1, -2.425, -6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -1.775, -6.15, -1.475, -6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -1.475, -6.15, -1.475, -7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -1.475, -7.1, -1.775, -7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -1.775, -7.1, -1.775, -6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -1.125, -6.15, -0.825, -6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -0.825, -6.15, -0.825, -7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -0.825, -7.1, -1.125, -7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -1.125, -7.1, -1.125, -6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -0.475, -6.15, -0.175, -6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -0.175, -6.15, -0.175, -7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -0.175, -7.1, -0.475, -7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -0.475, -7.1, -0.475, -6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 0.175, -6.15, 0.475, -6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 0.475, -6.15, 0.475, -7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 0.475, -7.1, 0.175, -7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 0.175, -7.1, 0.175, -6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 0.825, -6.15, 1.125, -6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 1.125, -6.15, 1.125, -7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 1.125, -7.1, 0.825, -7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 0.825, -7.1, 0.825, -6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 1.475, -6.15, 1.775, -6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 1.775, -6.15, 1.775, -7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 1.775, -7.1, 1.475, -7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 1.475, -7.1, 1.475, -6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 2.125, -6.15, 2.425, -6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 2.425, -6.15, 2.425, -7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 2.425, -7.1, 2.125, -7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 2.125, -7.1, 2.125, -6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 2.775, -6.15, 3.075, -6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 3.075, -6.15, 3.075, -7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 3.075, -7.1, 2.775, -7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 2.775, -7.1, 2.775, -6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 3.425, -6.15, 3.725, -6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 3.725, -6.15, 3.725, -7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 3.725, -7.1, 3.425, -7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 3.425, -7.1, 3.425, -6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 4.075, -6.15, 4.375, -6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 4.375, -6.15, 4.375, -7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 4.375, -7.1, 4.075, -7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 4.075, -7.1, 4.075, -6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 4.725, -6.15, 5.025, -6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 5.025, -6.15, 5.025, -7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 5.025, -7.1, 4.725, -7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 4.725, -7.1, 4.725, -6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 5.375, -6.15, 5.675, -6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 5.675, -6.15, 5.675, -7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 5.675, -7.1, 5.375, -7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 5.375, -7.1, 5.375, -6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 5.675, 6.15, 5.375, 6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 5.375, 6.15, 5.375, 7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 5.375, 7.1, 5.675, 7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 5.675, 7.1, 5.675, 6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 5.025, 6.15, 4.725, 6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 4.725, 6.15, 4.725, 7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 4.725, 7.1, 5.025, 7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 5.025, 7.1, 5.025, 6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 4.375, 6.15, 4.075, 6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 4.075, 6.15, 4.075, 7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 4.075, 7.1, 4.375, 7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 4.375, 7.1, 4.375, 6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 3.725, 6.15, 3.425, 6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 3.425, 6.15, 3.425, 7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 3.425, 7.1, 3.725, 7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 3.725, 7.1, 3.725, 6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 3.075, 6.15, 2.775, 6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 2.775, 6.15, 2.775, 7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 2.775, 7.1, 3.075, 7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 3.075, 7.1, 3.075, 6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 2.425, 6.15, 2.125, 6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 2.125, 6.15, 2.125, 7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 2.125, 7.1, 2.425, 7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 2.425, 7.1, 2.425, 6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 1.775, 6.15, 1.475, 6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 1.475, 6.15, 1.475, 7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 1.475, 7.1, 1.775, 7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 1.775, 7.1, 1.775, 6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 1.125, 6.15, 0.825, 6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 0.825, 6.15, 0.825, 7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 0.825, 7.1, 1.125, 7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 1.125, 7.1, 1.125, 6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 0.475, 6.15, 0.175, 6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 0.175, 6.15, 0.175, 7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 0.175, 7.1, 0.475, 7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 0.475, 7.1, 0.475, 6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -0.175, 6.15, -0.475, 6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -0.475, 6.15, -0.475, 7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -0.475, 7.1, -0.175, 7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -0.175, 7.1, -0.175, 6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -0.825, 6.15, -1.125, 6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -1.125, 6.15, -1.125, 7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -1.125, 7.1, -0.825, 7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -0.825, 7.1, -0.825, 6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -1.475, 6.15, -1.775, 6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -1.775, 6.15, -1.775, 7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -1.775, 7.1, -1.475, 7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -1.475, 7.1, -1.475, 6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -2.125, 6.15, -2.425, 6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -2.425, 6.15, -2.425, 7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -2.425, 7.1, -2.125, 7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -2.125, 7.1, -2.125, 6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -2.775, 6.15, -3.075, 6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -3.075, 6.15, -3.075, 7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -3.075, 7.1, -2.775, 7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -2.775, 7.1, -2.775, 6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -3.425, 6.15, -3.725, 6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -3.725, 6.15, -3.725, 7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -3.725, 7.1, -3.425, 7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -3.425, 7.1, -3.425, 6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -4.075, 6.15, -4.375, 6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -4.375, 6.15, -4.375, 7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -4.375, 7.1, -4.075, 7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -4.075, 7.1, -4.075, 6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -4.725, 6.15, -5.025, 6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -5.025, 6.15, -5.025, 7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -5.025, 7.1, -4.725, 7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -4.725, 7.1, -4.725, 6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -5.375, 6.15, -5.675, 6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -5.675, 6.15, -5.675, 7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -5.675, 7.1, -5.375, 7.1, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -5.375, 7.1, -5.375, 6.15, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -3.8, -3, 4.3, -3, eMechanical12, 0.025, False);
        CreateComponentArc(NewPCBLibComp, 4.3, -2.5, 0.5, 270, 360, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 4.8, -2.5, 4.8, 2.5, eMechanical12, 0.025, False);
        CreateComponentArc(NewPCBLibComp, 4.3, 2.5, 0.5, 0, 90, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 4.3, 3, -4.3, 3, eMechanical12, 0.025, False);
        CreateComponentArc(NewPCBLibComp, -4.3, 2.5, 0.5, 90, 180, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -4.8, 2.5, -4.8, -2, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -4.8, -2, -3.8, -3, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -7.95, -5.5, -7.95, 5.5, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -7.95, 5.5, 7.95, 5.5, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 7.95, 5.5, 7.95, -5.5, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 7.95, -5.5, -7.95, -5.5, eMechanical12, 0.025, False);
        CreateComponentArc(NewPCBLibComp, 0, 0, 0.25, 0, 360, eMechanical15, 0.05, False);
        CreateComponentTrack(NewPCBLibComp, 0, 0.35, 0, -0.35, eMechanical15, 0.05, False);
        CreateComponentTrack(NewPCBLibComp, -0.35, 0, 0.35, 0, eMechanical15, 0.05, False);
        CreateComponentTrack(NewPCBLibComp, -8, -5.55, -8, 5.55, eMechanical11, 0.12, False);
        CreateComponentTrack(NewPCBLibComp, -8, 5.55, 8, 5.55, eMechanical11, 0.12, False);
        CreateComponentTrack(NewPCBLibComp, 8, 5.55, 8, -5.55, eMechanical11, 0.12, False);
        CreateComponentTrack(NewPCBLibComp, 8, -5.55, -8, -5.55, eMechanical11, 0.12, False);
        CreateComponentTrack(NewPCBLibComp, 8.2, -5.75, 8.2, 5.75, eMechanical15, 0.05, False);
        CreateComponentTrack(NewPCBLibComp, 8.2, 5.75, 5.955, 5.75, eMechanical15, 0.05, False);
        CreateComponentTrack(NewPCBLibComp, 5.955, 5.75, 5.955, 7.655, eMechanical15, 0.05, False);
        CreateComponentTrack(NewPCBLibComp, 5.955, 7.655, -5.955, 7.655, eMechanical15, 0.05, False);
        CreateComponentTrack(NewPCBLibComp, -5.955, 7.655, -5.955, 5.75, eMechanical15, 0.05, False);
        CreateComponentTrack(NewPCBLibComp, -5.955, 5.75, -8.2, 5.75, eMechanical15, 0.05, False);
        CreateComponentTrack(NewPCBLibComp, -8.2, 5.75, -8.2, -5.75, eMechanical15, 0.05, False);
        CreateComponentTrack(NewPCBLibComp, -8.2, -5.75, -5.955, -5.75, eMechanical15, 0.05, False);
        CreateComponentTrack(NewPCBLibComp, -5.955, -5.75, -5.955, -7.655, eMechanical15, 0.05, False);
        CreateComponentTrack(NewPCBLibComp, -5.955, -7.655, 5.955, -7.655, eMechanical15, 0.05, False);
        CreateComponentTrack(NewPCBLibComp, 5.955, -7.655, 5.955, -5.75, eMechanical15, 0.05, False);
        CreateComponentTrack(NewPCBLibComp, 5.955, -5.75, 8.2, -5.75, eMechanical15, 0.05, False);
        CreateComponentTrack(NewPCBLibComp, 5.935, -5.55, 8, -5.55, eTopOverlay, 0.12, False);
        CreateComponentTrack(NewPCBLibComp, 8, -5.55, 8, 5.55, eTopOverlay, 0.12, False);
        CreateComponentTrack(NewPCBLibComp, 8, 5.55, 5.935, 5.55, eTopOverlay, 0.12, False);
        CreateComponentTrack(NewPCBLibComp, -5.935, -5.55, -8, -5.55, eTopOverlay, 0.12, False);
        CreateComponentTrack(NewPCBLibComp, -8, -5.55, -8, 5.55, eTopOverlay, 0.12, False);
        CreateComponentTrack(NewPCBLibComp, -8, 5.55, -5.935, 5.55, eTopOverlay, 0.12, False);

        CurrentLib.RegisterComponent(NewPCBLibComp);
        CurrentLib.CurrentComponent := NewPcbLibComp;
    Finally
        PCBServer.PostProcess;
    End;

    CurrentLib.Board.ViewManager_UpdateLayerTabs;
    CurrentLib.Board.ViewManager_FullUpdate;
    Client.SendMessage('PCB:Zoom', 'Action=All' , 255, Client.CurrentView)
End;

Procedure CreateAPCBLibrary(Zero : integer);
Var
    Document : IServerDocument;

Begin
    Document := CreateNewDocumentFromDocumentKind('PCBLib');

    If PCBServer = Nil Then
    Begin
        ShowMessage('No PCBServer present. This script inserts a footprint into an existing PCB Library that has the current focus.');
        Exit;
    End;

    CurrentLib := PcbServer.GetCurrentPCBLibrary;
    If CurrentLib = Nil Then
    Begin
        ShowMessage('You must have focus on a PCB Library in order for this script to run.');
        Exit;
    End;

    Document.Modified := True;

    CreateComponentSOP37P65_1590X1420X360L95X30T960X600N(0);
End;

Procedure CreateALibrary;
Begin
    Screen.Cursor := crHourGlass;

    CreateAPCBLibrary(0);

    Screen.Cursor := crArrow;
End;

End.
