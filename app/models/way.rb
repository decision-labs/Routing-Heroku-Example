class Way < SpacialdbBase
  set_primary_key "gid"
  def self.find_route(method, start_x, start_y, end_x, end_y)

    start_edge   = find_nearest_edge(start_x, start_y).first
    finish_edge  = find_nearest_edge(end_x, end_y).first

    case method

    when "SPD"     #  Shortest Path Dijkstra 

      sql = "SELECT rt.gid, AsText(transform(rt.the_geom, 900913)) AS wkt,
      length(rt.the_geom) AS length, ways.gid
      FROM ways,
      (SELECT gid, the_geom
        FROM dijkstra_sp_delta( 'ways', #{start_edge.source}, #{finish_edge.target},4)
      ) as rt
      WHERE ways.gid=rt.gid;"

    when "SPA"    # Shortest Path A* 

      sql = "SELECT rt.gid, AsText(rt.the_geom) AS wkt, 
      length(rt.the_geom) AS length, ways.gid 
      FROM ways, 
      (SELECT gid, the_geom 
        FROM astar_sp_delta('ways', #{start_edge.source},  #{finish_edge.target}, 4)
      ) as rt 
      WHERE ways.gid=rt.gid;"
  
    when 'SPS'  # Shortest Path Shooting*

      sql = "SELECT rt.gid, AsText(rt.the_geom) AS wkt, 
      length(rt.the_geom) AS length, ways.gid 
      FROM ways, 
      (SELECT gid, the_geom 
        FROM shootingstar_sp('ways', start_edge.gid, end_edge.gid, 3, 'length', false, false)
      ) as rt 
      WHERE ways.gid=rt.gid;"
      end
  
    find_by_sql(sql)
  end

  def self.as_json_hash(route) # not the best way to do this... TODO: user GeoRuby to parse geometry
    linestrs = []
    route.each{|r| linestrs <<  r.wkt.delete("MULTILINESTRING(").delete("(").delete(")").split(",") }

    arr_of_points = linestrs.flatten.map!{|v| v.split(" ").map{|v| v.to_f }}

    {"type"=>"FeatureCollection","features"=>[{
        "type"=>"Feature", "id"=>"OpenLayers.Feature.Vector_#{rand(100)}",
        "properties" => { "title"=>"Route", "strokeColor"=>"red", "author"=>"Shoaib" },
        "geometry"   => { "type"=>"LineString",  "coordinates"=>arr_of_points } 
      }]
    }
  end
  protected
  def self.find_nearest_edge(x, y)
    sql =  "SELECT gid, source, target, the_geom, 
            distance(the_geom, GeometryFromText( 'POINT(#{x} #{y})', 4326)) AS dist 
      FROM Ways  WHERE the_geom && setsrid(
      'BOX3D(  #{x-0.0200}
        #{y-0.0200}, 
        #{x+0.0200}
        #{y+0.0200})'::box3d, 4326) 
      ORDER BY dist LIMIT 1" 
    find_by_sql(sql)
  end
end
