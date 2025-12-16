    // 1. Define Multi-Dimensional Array (studentData)
   // Format: [Name (String), Credit Hour (Number), Current GPA (Number)]
   var studentData = [
    ["Ali bin Ahmad", 15, 3.75],
    ["Bala A/L Muthu", 12, 3.40],
    ["Siti Nurhaliza", 18, 4.00],
    ["Wong Mei Ling", 10, 3.50],
    ["David Lee", 15, 2.95]
   ];

   // 2. Create function to measure dean list eligibility using conditional statement
   function checkDeanList(gpa) {
    if (gpa >= 3.50) {
        return "Dean's List Eligible";
    } else {
        return "Not Dean's List Eligible";
    }
   }
   
   // get output container
   var output = document.getElementById("output")
   output.innerHTML = "<div class='output-box'><h2>Section 03 Result</h2>";

  // 3. Create Looping (for loop)
  for (var i = 0; i < studentData.length; i++) {

    var name = studentData[i][0];
    var creditHour = studentData[i][1];
    var gpa = studentData[i][2];
    var status = checkDeanList(gpa);

    // 4. Print output (INSIDE loop)
    output.innerHTML +=
        "<div>" +
        "<b>Name:</b> " + name + "<br>" +
        "<b>Credit Hours:</b> " + creditHour + "<br>" +
        "<b>Current GPA:</b> " + gpa + "<br>" +
        "<b>Status:</b> " + status + "<br>" +
        "<hr style='border-top: 1px dotted #ccc;'>" +
        "</div>";
   }
  // close output-box (OUTSIDE loop)
  output.innerHTML += "</div>";
