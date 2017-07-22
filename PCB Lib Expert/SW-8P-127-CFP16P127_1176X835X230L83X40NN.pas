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

Procedure CreateComponentSW_8P_127_CFP16P127_1176X835X230L83X40NN(Zero : integer);
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
        NewPcbLibComp.Name := 'SW-8P-127-CFP16P127_1176X835X230L83X40NN';
        NewPCBLibComp.Description := 'Ceramic Flat Pack (CFP), 1.27 mm pitch; 16 pin, 11.76 mm L X 5.40 mm W X 2.30 mm H body';
        NewPCBLibComp.Height := MMsToCoord(2.3);

        // Create text object for .Designator
        TextObj := PCBServer.PCBObjectFactory(eTextObject, eNoDimension, eCreate_Default);
        TextObj.UseTTFonts := True;
        TextObj.Layer := eMechanical16;
        TextObj.Text := '.Designator';
        TextObj.Size := MMsToCoord(1.2);
        NewPCBLibComp.AddPCBObject(TextObj);
        PCBServer.SendMessageToRobots(NewPCBLibComp.I_ObjectAddress,c_Broadcast,PCBM_BoardRegisteration,TextObj.I_ObjectAddress);

        CreateSMDComponentPad(NewPCBLibComp, '1', eTopLayer, -4.445, -3.71, 0, 0, eRoundedRectangular, 1.74, 0.63, 270, 50.79, 0, 0, True, True);
        CreateSMDComponentPad(NewPCBLibComp, '2', eTopLayer, -3.175, -3.71, 0, 0, eRoundedRectangular, 1.74, 0.63, 270, 50.79, 0, 0, True, True);
        CreateSMDComponentPad(NewPCBLibComp, '3', eTopLayer, -1.905, -3.71, 0, 0, eRoundedRectangular, 1.74, 0.63, 270, 50.79, 0, 0, True, True);
        CreateSMDComponentPad(NewPCBLibComp, '4', eTopLayer, -0.635, -3.71, 0, 0, eRoundedRectangular, 1.74, 0.63, 270, 50.79, 0, 0, True, True);
        CreateSMDComponentPad(NewPCBLibComp, '5', eTopLayer, 0.635, -3.71, 0, 0, eRoundedRectangular, 1.74, 0.63, 270, 50.79, 0, 0, True, True);
        CreateSMDComponentPad(NewPCBLibComp, '6', eTopLayer, 1.905, -3.71, 0, 0, eRoundedRectangular, 1.74, 0.63, 270, 50.79, 0, 0, True, True);
        CreateSMDComponentPad(NewPCBLibComp, '7', eTopLayer, 3.175, -3.71, 0, 0, eRoundedRectangular, 1.74, 0.63, 270, 50.79, 0, 0, True, True);
        CreateSMDComponentPad(NewPCBLibComp, '8', eTopLayer, 4.445, -3.71, 0, 0, eRoundedRectangular, 1.74, 0.63, 270, 50.79, 0, 0, True, True);
        CreateSMDComponentPad(NewPCBLibComp, '9', eTopLayer, 4.445, 3.71, 0, 0, eRoundedRectangular, 1.74, 0.63, 90, 50.79, 0, 0, True, True);
        CreateSMDComponentPad(NewPCBLibComp, '10', eTopLayer, 3.175, 3.71, 0, 0, eRoundedRectangular, 1.74, 0.63, 90, 50.79, 0, 0, True, True);
        CreateSMDComponentPad(NewPCBLibComp, '11', eTopLayer, 1.905, 3.71, 0, 0, eRoundedRectangular, 1.74, 0.63, 90, 50.79, 0, 0, True, True);
        CreateSMDComponentPad(NewPCBLibComp, '12', eTopLayer, 0.635, 3.71, 0, 0, eRoundedRectangular, 1.74, 0.63, 90, 50.79, 0, 0, True, True);
        CreateSMDComponentPad(NewPCBLibComp, '13', eTopLayer, -0.635, 3.71, 0, 0, eRoundedRectangular, 1.74, 0.63, 90, 50.79, 0, 0, True, True);
        CreateSMDComponentPad(NewPCBLibComp, '14', eTopLayer, -1.905, 3.71, 0, 0, eRoundedRectangular, 1.74, 0.63, 90, 50.79, 0, 0, True, True);
        CreateSMDComponentPad(NewPCBLibComp, '15', eTopLayer, -3.175, 3.71, 0, 0, eRoundedRectangular, 1.74, 0.63, 90, 50.79, 0, 0, True, True);
        CreateSMDComponentPad(NewPCBLibComp, '16', eTopLayer, -4.445, 3.71, 0, 0, eRoundedRectangular, 1.74, 0.63, 90, 50.79, 0, 0, True, True);

        CreateComponentTrack(NewPCBLibComp, -4.645, -3.345, -4.245, -3.345, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -4.245, -3.345, -4.245, -4.175, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -4.245, -4.175, -4.645, -4.175, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -4.645, -4.175, -4.645, -3.345, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -3.375, -3.345, -2.975, -3.345, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -2.975, -3.345, -2.975, -4.175, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -2.975, -4.175, -3.375, -4.175, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -3.375, -4.175, -3.375, -3.345, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -2.105, -3.345, -1.705, -3.345, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -1.705, -3.345, -1.705, -4.175, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -1.705, -4.175, -2.105, -4.175, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -2.105, -4.175, -2.105, -3.345, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -0.835, -3.345, -0.435, -3.345, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -0.435, -3.345, -0.435, -4.175, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -0.435, -4.175, -0.835, -4.175, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -0.835, -4.175, -0.835, -3.345, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 0.435, -3.345, 0.835, -3.345, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 0.835, -3.345, 0.835, -4.175, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 0.835, -4.175, 0.435, -4.175, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 0.435, -4.175, 0.435, -3.345, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 1.705, -3.345, 2.105, -3.345, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 2.105, -3.345, 2.105, -4.175, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 2.105, -4.175, 1.705, -4.175, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 1.705, -4.175, 1.705, -3.345, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 2.975, -3.345, 3.375, -3.345, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 3.375, -3.345, 3.375, -4.175, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 3.375, -4.175, 2.975, -4.175, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 2.975, -4.175, 2.975, -3.345, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 4.245, -3.345, 4.645, -3.345, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 4.645, -3.345, 4.645, -4.175, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 4.645, -4.175, 4.245, -4.175, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 4.245, -4.175, 4.245, -3.345, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 4.645, 3.345, 4.245, 3.345, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 4.245, 3.345, 4.245, 4.175, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 4.245, 4.175, 4.645, 4.175, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 4.645, 4.175, 4.645, 3.345, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 3.375, 3.345, 2.975, 3.345, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 2.975, 3.345, 2.975, 4.175, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 2.975, 4.175, 3.375, 4.175, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 3.375, 4.175, 3.375, 3.345, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 2.105, 3.345, 1.705, 3.345, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 1.705, 3.345, 1.705, 4.175, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 1.705, 4.175, 2.105, 4.175, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 2.105, 4.175, 2.105, 3.345, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 0.835, 3.345, 0.435, 3.345, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 0.435, 3.345, 0.435, 4.175, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 0.435, 4.175, 0.835, 4.175, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 0.835, 4.175, 0.835, 3.345, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -0.435, 3.345, -0.835, 3.345, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -0.835, 3.345, -0.835, 4.175, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -0.835, 4.175, -0.435, 4.175, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -0.435, 4.175, -0.435, 3.345, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -1.705, 3.345, -2.105, 3.345, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -2.105, 3.345, -2.105, 4.175, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -2.105, 4.175, -1.705, 4.175, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -1.705, 4.175, -1.705, 3.345, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -2.975, 3.345, -3.375, 3.345, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -3.375, 3.345, -3.375, 4.175, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -3.375, 4.175, -2.975, 4.175, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -2.975, 4.175, -2.975, 3.345, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -4.245, 3.345, -4.645, 3.345, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -4.645, 3.345, -4.645, 4.175, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -4.645, 4.175, -4.245, 4.175, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -4.245, 4.175, -4.245, 3.345, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -5.88, -2.7, -5.88, 2.7, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, -5.88, 2.7, 5.88, 2.7, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 5.88, 2.7, 5.88, -2.7, eMechanical12, 0.025, False);
        CreateComponentTrack(NewPCBLibComp, 5.88, -2.7, -5.88, -2.7, eMechanical12, 0.025, False);
        CreateComponentArc(NewPCBLibComp, 0, 0, 0.25, 0, 360, eMechanical15, 0.05, False);
        CreateComponentTrack(NewPCBLibComp, 0, 0.35, 0, -0.35, eMechanical15, 0.05, False);
        CreateComponentTrack(NewPCBLibComp, -0.35, 0, 0.35, 0, eMechanical15, 0.05, False);
        CreateComponentTrack(NewPCBLibComp, -5.88, -2.7, -5.88, 2.7, eMechanical11, 0.12, False);
        CreateComponentTrack(NewPCBLibComp, -5.88, 2.7, 5.88, 2.7, eMechanical11, 0.12, False);
        CreateComponentTrack(NewPCBLibComp, 5.88, 2.7, 5.88, -2.7, eMechanical11, 0.12, False);
        CreateComponentTrack(NewPCBLibComp, 5.88, -2.7, -5.88, -2.7, eMechanical11, 0.12, False);
        CreateComponentTrack(NewPCBLibComp, 6.08, -2.9, 6.08, 2.9, eMechanical15, 0.05, False);
        CreateComponentTrack(NewPCBLibComp, 6.08, 2.9, 4.96, 2.9, eMechanical15, 0.05, False);
        CreateComponentTrack(NewPCBLibComp, 4.96, 2.9, 4.96, 4.78, eMechanical15, 0.05, False);
        CreateComponentTrack(NewPCBLibComp, 4.96, 4.78, -4.96, 4.78, eMechanical15, 0.05, False);
        CreateComponentTrack(NewPCBLibComp, -4.96, 4.78, -4.96, 2.9, eMechanical15, 0.05, False);
        CreateComponentTrack(NewPCBLibComp, -4.96, 2.9, -6.08, 2.9, eMechanical15, 0.05, False);
        CreateComponentTrack(NewPCBLibComp, -6.08, 2.9, -6.08, -2.9, eMechanical15, 0.05, False);
        CreateComponentTrack(NewPCBLibComp, -6.08, -2.9, -4.96, -2.9, eMechanical15, 0.05, False);
        CreateComponentTrack(NewPCBLibComp, -4.96, -2.9, -4.96, -4.78, eMechanical15, 0.05, False);
        CreateComponentTrack(NewPCBLibComp, -4.96, -4.78, 4.96, -4.78, eMechanical15, 0.05, False);
        CreateComponentTrack(NewPCBLibComp, 4.96, -4.78, 4.96, -2.9, eMechanical15, 0.05, False);
        CreateComponentTrack(NewPCBLibComp, 4.96, -2.9, 6.08, -2.9, eMechanical15, 0.05, False);
        CreateComponentTrack(NewPCBLibComp, 4.94, -2.7, 5.88, -2.7, eTopOverlay, 0.12, False);
        CreateComponentTrack(NewPCBLibComp, 5.88, -2.7, 5.88, 2.7, eTopOverlay, 0.12, False);
        CreateComponentTrack(NewPCBLibComp, 5.88, 2.7, 4.94, 2.7, eTopOverlay, 0.12, False);
        CreateComponentTrack(NewPCBLibComp, -4.94, -2.7, -5.88, -2.7, eTopOverlay, 0.12, False);
        CreateComponentTrack(NewPCBLibComp, -5.88, -2.7, -5.88, 2.7, eTopOverlay, 0.12, False);
        CreateComponentTrack(NewPCBLibComp, -5.88, 2.7, -4.94, 2.7, eTopOverlay, 0.12, False);

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

    CreateComponentSW_8P_127_CFP16P127_1176X835X230L83X40NN(0);
End;

Procedure CreateALibrary;
Begin
    Screen.Cursor := crHourGlass;

    CreateAPCBLibrary(0);

    Screen.Cursor := crArrow;
End;

End.
