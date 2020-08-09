package;

import tink.http.containers.*;
import tink.http.Response;
import tink.web.routing.*;
import bp.directory.routing.Router;
using tink.CoreApi;

typedef DataAccessRouter = bp.directory.routing.Router.DirectoryRouter<WildDuckUser>;

typedef WildDuckUser = {
	@:optional var _id:String;
	@:optional var username:String;
	@:optional var name:String;
	@:optional var password:String;
	@:optional var address:String;
	@:optional var storageUsed:Int;
	@:optional var created:Date;
}

class BackEndServer {
	public static function main() {
		var container = new NodeContainer(3960);
		var promise:Promise<bp.Mongo.MongoClient> = bp.Mongo.connect(js.node.Fs.readFileSync('./secrets/cnxStr').toString());
		promise.next(client -> {
			var router = new Router<BackEndRouter>(new BackEndRouter(client));
			container.run(function(req) {
				return router.route(Context.ofRequest(req)).recover(OutgoingResponse.reportError);
			});
		}).eager();
	}
}

class BackEndRouter {
	var client:bp.Mongo.MongoClient;

	public function new(client) {
		this.client = client;
	}

	@:sub('/users')
	public function users() {
		return new DataAccessRouter("users", () -> new bp.directory.providers.MongoProvider(client));
	}
}
