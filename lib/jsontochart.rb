require 'json'

class JSONToChart
  def initialize(file)
    @input = file
  end

  # Gets titles for columns and type of data then formats for table
  def columns
    data = JSON.parse(@input)
    keylist = Array.new
    columnstring = "\n"

    data.each do |l|
      dhash = Hash[*l.flatten]

      dhash.each_key do |key|
        # Check if the key is in the key list and if not add it (and check the type)
        if keylist.include? key
        else 
          keylist.push(key)
          if dhash[key].is_a? Integer
            columnstring = columnstring + "data.addColumn('number', '" + key + "');\n"
          elsif dhash[key].is_a? String
            columnstring = columnstring + "data.addColumn('string', '" + key + "');\n"
          elsif dhash[key] == true || dhash[key] == false
            columnstring = columnstring + "data.addColumn('boolean', '" + key + "');\n"
          else columnstring = columnstring + "data.addColumn('string', '" + key + "');\n"
          end
        end
      end
    end
 
    return columnstring
  end

  # Gets a list of all the column titles without formatting
  def columntitles
    data = JSON.parse(@input)
    keylist = Array.new

    data.each do |l|
      dhash = Hash[*l.flatten]
      dhash.each_key do |key|
        if keylist.include? key
        else keylist.push(key)
        end
      end
    end

    return keylist
  end

  # Converts data in JSON to format for table
  def rows(keylist)
    data = JSON.parse(@input)
    savestring = "data.addRows([\n"
    j = 0

    data.each do |l|
      dhash = Hash[*l.flatten]
      tmpstring = "["
      i = 0
      j += 1
      keylist.each do |key|
        i += 1
        # Add data correctly for the type
        if dhash[key] != nil 
          if dhash[key].is_a? String
            tmpstring = tmpstring + "'" + dhash[key] + "'"
          elsif dhash[key].is_a? Integer
            tmpstring = tmpstring + dhash[key].to_s
          elsif dhash[key] == true || dhash[key] == false
            tmpstring = tmpstring + dhash[key].to_s
          elsif dhash[key].is_a? Array
            hold = "'"
            z = 0
            dhash[key].each do |i|
              z += 1
              hold = hold + i.to_s
              if j < dhash[key].length
                hold = hold + ","
              end
            end
            hold = hold + "'"
            tmpstring = tmpstring + hold
          else tmpstring = tmpstring + "'" + dhash[key].to_s + "'"
          end
        else tmpstring = tmpstring + "null"
        end

        # Check if it is the end of the line and append correct characters
        if i == keylist.length then tmpstring = tmpstring + "]"
        else tmpstring = tmpstring + ","
        end
      end
      
      # Check if it is the end of the data or just the line and append correct characters
      if j == data.length then savestring = savestring + tmpstring + "\n]);\n"
      else savestring = savestring + tmpstring + ",\n"
      end
    end
    
    return savestring
  end

  # Outputs html for table and calls methods to get column titles and data
  def table
    headerhtml = "<html>
  <head>
    <script type='text/javascript' src='https://www.google.com/jsapi'></script>
    <script type='text/javascript'>
      google.load('visualization', '1', {packages:['table']});
      google.setOnLoadCallback(drawTable);
      function drawTable() {
        var data = new google.visualization.DataTable();"
      footerhtml = "var table = new
        google.visualization.Table(document.getElementById('table_div'));
        table.draw(data, {showRowNumber: true});
      }
    </script>
  </head>

  <body>
    <div id='table_div'></div>
  </body>
</html>"

    return headerhtml + columns + rows(columntitles) + footerhtml
  end
end
