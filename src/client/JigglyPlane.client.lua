--Services
local rs = game:WaitForChild("ReplicatedStorage")
local runS = game:GetService("RunService")

--Player Items
local Cam = game.Workspace.CurrentCamera
local Mouse = game.Players.LocalPlayer:GetMouse()

--Fusion
local Fusion = require(rs:WaitForChild("Fusion"))
local Hydrate = Fusion.Hydrate
local Value = Fusion.Value
local Computed = Fusion.Computed
local Spring = Fusion.Spring

--Main Componentns
local function JigglyMeshNew(props)
    --Getting all the need items from the mesh
    local JigglyMesh = props.JigglyPlaneMesh :: typeof(JigglyPlaneMesh)
    local MainBone = JigglyMesh:WaitForChild("Base"):WaitForChild("Main")
    
    --Main Values
    local MainBoneCF = Value(MainBone.WorldCFrame)
    
    --Hydrating all the bones
    for _,Bone: Bone in JigglyMesh.Base:GetChildren() do
        --Skipping th main bone
        if Bone.Name == "Main" then continue end

        --Getting the offset of the bone
        local BoneOffset = MainBone.WorldCFrame:ToObjectSpace(Bone.WorldCFrame)
        print(Bone.Name)

        Hydrate(Bone) {
            WorldCFrame = Spring(Computed(function()
                return (MainBoneCF:get()::CFrame):ToWorldSpace(BoneOffset)
            end), props.SpringSpeed, props.SpringDamping)
        }
    end

    --Starting to move the jiggly mesh
    runS.RenderStepped:Connect(function()
        --Getting the desired cf
        local MousePosition =  Mouse.Origin.Position + Mouse.Origin.LookVector * props.HoverDistance
        local FinalPlaneCF = CFrame.lookAt(MousePosition, Cam.CFrame.Position)

        --Setting the final cf
        MainBone.WorldCFrame = FinalPlaneCF
        MainBoneCF:set(FinalPlaneCF, true)
    end)

    return Hydrate(JigglyMesh) {
        Name = "JigglyMesh",
        Parent = props.Parent,
    }

end

--Creating the final jiggly component
local JigglyPlaneComp = JigglyMeshNew {
    --Main Props
    Parent = workspace,
    JigglyPlaneMesh = rs:WaitForChild("Plane"):Clone(), --The mesh of the jiggly plane
    HoverDistance = 5, --How far the jiggly part hovers infront of the mouse

    --Spring Props
    SpringSpeed = nil, --The speed of the bone springs
    SpringDamping = 1.5, --The damping of the bone springs
}
