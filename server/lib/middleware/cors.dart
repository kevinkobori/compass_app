import 'package:shelf/shelf.dart';

/// Middleware that adds basic CORS headers and handles preflight requests.
Middleware cors() => (Handler innerHandler) {
  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Authorization, Content-Type',
  };

  return (Request request) async {
    // Handle preflight CORS requests by returning early with headers.
    if (request.method == 'OPTIONS') {
      return Response.ok('', headers: corsHeaders);
    }

    final response = await innerHandler(request);
    return response.change(headers: corsHeaders);
  };
};
