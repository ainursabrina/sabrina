// 1. Define Multi-Dimensional Array studentData)
// Format: [Name (String), Credit Hour (Number), Current GPA (Number)]

// -- AI ASSISTED CODE START --
// Array initialization and logic for eligibility checking
let studentData = [
    ["Ali Bin Ahmad", 15, 3.75],
    ["Bala A/L Muthu", 12, 3.40],
    ["Siti Nurhaliza", 18, 4.00],
    ["Wong Mei Ling", 10, 3.50],
    ["David Lee", 15, 2.95]
];
// -- AI ASSISTED CODE END --


// -- AI ASSISTED CODE START --
// Logic for the checkDeanList function
// 2. Create function to measure dean list eligibility using conditional statement
function checkDeanList(credit, gpa) {
    if (credit >= 12 && gpa >= 3.50) {
        return "Eligible for Dean's List";
    } else {
        return "Not Eligible for Dean's List";
    }
}
// -- AI ASSISTED CODE END --


// Auto display result when page loads
window.onload = function () {

    let output = "<h2>Section 03 Result</h2>";

    // 3.Create Looping (for loop) to print student data such name,
    // credithours and current gpa and their eligibility (status)
    for (let i = 0; i < studentData.length; i++) {

        let status = checkDeanList(studentData[i][1], studentData[i][2]);

        // 4. print all the output, this one need to be in the loop
        output += "<div>";
        output += "<b>Name:</b> " + studentData[i][0] + "<br>";
        output += "<b>Credit Hours:</b> " + studentData[i][1] + "<br>";
        output += "<b>Current GPA:</b> " + studentData[i][2] + "<br>";

        if (status.includes("Eligible")) {
            output += "<b>Status:</b> <span class='eligible'>" + status + "</span><br>";
        } else {
            output += "<b>Status:</b> <span class='not-eligible'>" + status + "</span><br>";
        }

        output += "<hr style='border-top: 1px dotted #ccc;'>";
        output += "</div>";
    }

    document.getElementById("result").innerHTML = output;
};
;
