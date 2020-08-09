import tink.http.containers.*;
import tink.http.Response;
import tink.web.routing.*;
import tink.http.clients.*;
import bp.directory.routing.Router;
import BackEndServer;

using tink.CoreApi;
using tink.io.Source;

class FrontEndServer2 {
	static function main() {
		var container = new NodeContainer(8080);
		var router = new Router<Root>(new Root());
		container.run(function(req) {
			return router.route(Context.ofRequest(req)).recover(OutgoingResponse.reportError);
		});
	}
}

class Root {
	var remote:tink.web.proxy.Remote<BackEndRouter>;

	public function new() {
		this.remote = tink.Web.connect(("http://localhost:3960" : BackEndRouter), {client: new NodeClient()});
	}

	@:get('/users/')
	@:html(function(o) return '<h2>User Directory</h2>
		<ul>
		${o.map(user -> '<li><a href="/user/${user._id}">${user.username}</a> (<a href="mailto:${user.address}">${user.address}</a>)</li>').join('')}
				</ul>')
	public function users(?skip = 0, ?limit = 100) {
		return remote.users()
			.list({
				_skip: skip,
				_limit: limit,
				_select: {
					_id: 1,
					username: 1,
					address: 1
				}
			})
			.next(r -> r.body.all())
			.next(d -> (tink.Json.parse(d) : Array<WildDuckUser>));
	}
}
