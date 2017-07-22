Var
    CurrentSCHLib : ISch_Lib;
    CurrentLib : IPCB_Library;

Procedure CreateTHComponentPad(NewPCBLibComp : IPCB_LibComponent, Name : String, HoleType : TExtendedHoleType,
                               HoleSize : Real, HoleLength : Real, Layer : TLayer, X : Real, Y : Real,
                               OffsetX : Real, OffsetY : Real, TopShape : TShape, TopXSize : Real, TopYSize : Real,
                               InnerShape : TShape, InnerXSize : Real, InnerYSize : Real,
                               BottomShape : TShape, BottomXSize : Real, BottomYSize : Real,
                               Rotation: Real, CRRatio : Real, PMExpansion : Real, SMExpansion: Real, Plated : Boolean);
Var
    NewPad                      : IPCB_Pad2;
    PadCache                    : TPadCache;

Begin
    NewPad := PcbServer.PCBObjectFactory(ePadObject, eNoDimension, eCreate_Default);
    NewPad.HoleType := HoleType;
    NewPad.HoleSize := MMsToCoord(HoleSize);
    if HoleLength <> 0 then
        NewPad.HoleWidth := MMsToCoord(HoleLength);
    NewPad.TopShape := TopShape;
    if TopShape = eRoundedRectangular then
        NewPad.SetState_StackCRPctOnLayer(eTopLayer, CRRatio);
    if BottomShape = eRoundedRectangular then
        NewPad.SetState_StackCRPctOnLayer(eBottomLayer, CRRatio);
    NewPad.TopXSize := MMsToCoord(TopXSize);
    NewPad.TopYSize := MMsToCoord(TopYSize);
    NewPad.MidShape := InnerShape;
    NewPad.MidXSize := MMsToCoord(InnerXSize);
    NewPad.MidYSize := MMsToCoord(InnerYSize);
    NewPad.BotShape := BottomShape;
    NewPad.BotXSize := MMsToCoord(BottomXSize);
    NewPad.BotYSize := MMsToCoord(BottomYSize);
    NewPad.SetState_XPadOffsetOnLayer(Layer, MMsToCoord(OffsetX));
    NewPad.SetState_YPadOffsetOnLayer(Layer, MMsToCoord(OffsetY));
    NewPad.RotateBy(Rotation);
    NewPad.MoveToXY(MMsToCoord(X), MMsToCoord(Y));
    NewPad.Plated   := Plated;
    NewPad.Name := Name;

    Padcache := NewPad.GetState_Cache;
    if PMExpansion <> 0 then
    Begin
        Padcache.PasteMaskExpansionValid   := eCacheManual;
        Padcache.PasteMaskExpansion        := MMsToCoord(PMExpansion);
    End;
    if SMExpansion <> 0 then
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

Procedure CreateComponentResAdj_SIP483W55P254L953H1000Q3(Zero : integer);
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
        NewPcbLibComp.Name := 'ResAdj-SIP483W55P254L953H1000Q3';
        NewPCBLibComp.Description := 'SIP, 2.54 mm pitch; 3 pin, 9.53 mm L X 4.83 mm W X 10.00 mm H body';
        NewPCBLibComp.Height := MMsToCoord(10);

        // Create text object for .Designator
        TextObj := PCBServer.PCBObjectFactory(eTextObject, eNoDimension, eCreate_Default);
        TextObj.UseTTFonts := True;
        TextObj.Layer := eMechanical16;
        TextObj.Text := '.Designator';
        TextObj.Size := MMsToCoord(1.2);
        NewPCBLibComp.AddPCBObject(TextObj);
        PCBServer.SendMessageToRobots(NewPCBLibComp.I_ObjectAddress,c_Broadcast,PCBM_BoardRegisteration,TextObj.I_ObjectAddress);

        CreateTHComponentPad(NewPCBLibComp, '1', eRoundHole, 0.8, 0, eBottomLayer, 0, 0, 0, 0, eRectangular, 1.2, 1.2, eRounded, 1.2, 1.2, eRectangular, 1.2, 1.2, 90, 0, -1.2, 0, True);
        CreateTHComponentPad(NewPCBLibComp, '2', eRoundHole, 0.8, 0, eBottomLayer, 2.54, 0, 0, 0, eRounded, 1.2, 1.2, eRounded, 1.2, 1.2, eRounded, 1.2, 1.2, 0, 0, -1.2, 0, True);
        CreateTHComponentPad(NewPCBLibComp, '3', eRoundHole, 0.8, 0, eBottomLayer, 5.08, 0, 0, 0, eRounded, 1.2, 1.2, eRounded, 1.2, 1.2, eRounded, 1.2, 1.2, 0, 0, -1.2, 0, True);

        CreateComponentArc(NewPCBLibComp, 0, 0, 0.3, 0, 360, eMechanical12, 0.025, False);
        CreateComponentArc(NewPCBLibComp, 2.54, 0, 0.3, 0, 360, eMechanical12, 0.025, False);
        CreateComponentArc(NewPCBLibComp, 5.08, 0, 0.3, 0, 360, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -2.225, -2.415, -2.225, 2.415, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -2.225, 2.415, 7.305, 2.415, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 7.305, 2.415, 7.305, -2.415, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 7.305, -2.415, -2.225, -2.415, eMechanical12, 0.025, False);
        CreateComponentArc(NewPCBLibComp, 0, 0, 0.25, 0, 360, eMechanical15, 0.05, False);
        CreateComponentTrack(NewPCBLibComp, 0, 0.35, 0, -0.35, eMechanical15, 0.05, False);
        CreateComponentTrack(NewPCBLibComp, -0.35, 0, 0.35, 0, eMechanical15, 0.05, False);
        CreateComponentTrack(NewPCBLibComp, -2.23, -2.42, -2.23, 2.42, eMechanical11, 0.12, False);
        CreateComponentTrack(NewPCBLibComp, -2.23, 2.42, 7.31, 2.42, eMechanical11, 0.12, False);
        CreateComponentTrack(NewPCBLibComp, 7.31, 2.42, 7.31, -2.42, eMechanical11, 0.12, False);
        CreateComponentTrack(NewPCBLibComp, 7.31, -2.42, -2.23, -2.42, eMechanical11, 0.12, False);
        CreateComponentTrack(NewPCBLibComp, 7.56, -2.67, 7.56, 2.67, eMechanical15, 0.05, False);
        CreateComponentTrack(NewPCBLibComp, 7.56, 2.67, -2.48, 2.67, eMechanical15, 0.05, False);
        CreateComponentTrack(NewPCBLibComp, -2.48, 2.67, -2.48, -2.67, eMechanical15, 0.05, False);
        CreateComponentTrack(NewPCBLibComp, -2.48, -2.67, 7.56, -2.67, eMechanical15, 0.05, False);
        CreateComponentTrack(NewPCBLibComp, -1.27, -2.42, -2.23, -2.42, eTopOverlay, 0.12, False);
        CreateComponentTrack(NewPCBLibComp, -2.23, -2.42, -2.23, 2.42, eTopOverlay, 0.12, False);
        CreateComponentTrack(NewPCBLibComp, -2.23, 2.42, -1.27, 2.42, eTopOverlay, 0.12, False);
        CreateComponentTrack(NewPCBLibComp, 6.35, -2.42, 7.31, -2.42, eTopOverlay, 0.12, False);
        CreateComponentTrack(NewPCBLibComp, 7.31, -2.42, 7.31, 2.42, eTopOverlay, 0.12, False);
        CreateComponentTrack(NewPCBLibComp, 7.31, 2.42, 6.35, 2.42, eTopOverlay, 0.12, False);

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

    CreateComponentResAdj_SIP483W55P254L953H1000Q3(0);
End;

Procedure CreateALibrary;
Begin
    Screen.Cursor := crHourGlass;

    CreateAPCBLibrary(0);

    Screen.Cursor := crArrow;
End;

End.
