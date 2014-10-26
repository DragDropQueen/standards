require 'sinatra'
module Standards
  class AdminApp < Sinatra::Base

html = <<HTML
<!DOCTYPE html>
<html lang='en'>
  <head>
    <meta charset='utf-8'>
    <meta content='width=device-width, initial-scale=1' name='viewport'>
    <title>Standards Admin App</title>
    <style  type="text/css">
      .hierarchy {
        position:         relative;
      }
      .hierarchy.selected > .background {
        border: 3px solid #383;
        color:  #383;
      }
      .hierarchy .background {
        background-color: #8d5;
        width:            10em;
        margin:           1em;
        padding:          0.5em;
        color:            #fff;
      }
      .hierarchy .subhierarchies {
        padding-left:     2em;
      }
    </style>
    <script src="http://d3js.org/d3.v3.min.js" charset="utf-8"></script>
    <script type="text/javascript">
      "use strict";

      document.addEventListener('DOMContentLoaded', function(){
        var structure = <%= @structure.to_json %>;

        var d3Container = d3.select('body').append('div').classed('structure', true)

        var addHierarchy = function(container, dataHierarchy, isRoot) {
          var d3Hierarchy = container.append('div').classed('hierarchy', true)
          if(isRoot) d3Hierarchy.classed('root', true)
          d3Hierarchy.append('div').classed('background', true).text(dataHierarchy.name);
          var d3Subhierarchies = d3Hierarchy.append('div').classed('subhierarchies', true)
          for(var i=0; i < dataHierarchy.subhierarchies.length; ++i) {
            d3Subhierarchies.call(function(fuck) {
              addHierarchy(fuck, dataHierarchy.subhierarchies[i], false)
            })
          }
        }

        addHierarchy(d3Container, structure.hierarchy, true)
        var selected = d3Container.select('.root')
        selected.classed('selected', true)
      });
    </script>
  </head>
  <body>
    <h1>Standards and Hierarchy</h1>
  </body>
</html>
HTML

    get '/' do
      # taken from one of the specs
      @structure = env['standards']['structure']
      h1 = @structure.add_hierarchy name: 'h1', parent_id: 1
      h2 = @structure.add_hierarchy name: 'h2', parent_id: h1.id
      h3 = @structure.add_hierarchy name: 'h3', parent_id: h2.id
      h4 = @structure.add_hierarchy name: 'h4', parent_id: h1.id
      erb html
    end
  end
end
