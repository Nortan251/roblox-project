--!strict
--[[
	Tidebound — Remotes
	Single RemoteEvent per direction with a typed message envelope.
	Security: ALL messages funnel through one router and are validated server-side.
	Phase 2 | AI-assisted | 2026-08-02
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Ensure the remotes folder exists (idempotent on both client and server)
local folder = ReplicatedStorage:FindFirstChild("TideboundRemotes")
if not folder then
	folder = Instance.new("Folder")
	folder.Name = "TideboundRemotes"
	folder.Parent = ReplicatedStorage
end

local c2s = folder:FindFirstChild("ClientToServer")
if not c2s then
	c2s = Instance.new("RemoteEvent")
	c2s.Name = "ClientToServer"
	c2s.Parent = folder
end

local s2c = folder:FindFirstChild("ServerToClient")
if not s2c then
	s2c = Instance.new("RemoteEvent")
	s2c.Name = "ServerToClient"
	s2c.Parent = folder
end

local Remotes = {
	ClientToServer = c2s :: RemoteEvent,
	ServerToClient = s2c :: RemoteEvent,
}

-- Client -> Server
function Remotes:SendToServer(message)
	self.ClientToServer:FireServer(message)
end

-- Server -> one client
function Remotes:SendToClient(player: Player, message)
	self.ServerToClient:FireClient(player, message)
end

-- Server -> all clients
function Remotes:SendToAll(message)
	self.ServerToClient:FireAllClients(message)
end

-- Server: subscribe to client messages. Handler(player, message).
function Remotes:OnServerMessage(handler: (Player, any) -> ())
	return self.ClientToServer.OnServerEvent:Connect(function(player, message)
		handler(player, message)
	end)
end

-- Client: subscribe to server messages. Handler(message).
function Remotes:OnClientMessage(handler: (any) -> ())
	return self.ServerToClient.OnClientEvent:Connect(function(message)
		handler(message)
	end)
end

return Remotes
