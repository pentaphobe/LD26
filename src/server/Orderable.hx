package server;

import com.haxepunk.HXP;

import utils.AgentTemplate;
import utils.AgentFactory;

import server.ServerEventHandler;
import server.ServerEvent;
import server.Server;
import server.Lobby;
import server.Player;

interface Orderable {
	public function onOrder(order:PlayerOrder):Bool;
}