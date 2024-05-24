import ballerinax/mi;

@mi:ConnectorInfo {}
public function weightedMean(xml results, xml weights) returns xml {

    // Extract values from the XMLs
    map<float> resultMap = extractValues(results);
    map<float> weightMap = extractValues(weights);

    // Calculate weighted mean
    float weightedSum = 0;
    float totalWeight = 0;

    foreach var key in resultMap.keys() {
        float? result = resultMap[key];
        float? weight = weightMap[key];
        if result is float && weight is float {
            weightedSum += result * weight;
            totalWeight += weight;
        }
    }

    float weightedMean = weightedSum / totalWeight;
    return xml `<weightedMean>${weightedMean}</weightedMean>`;
}

function extractValues(xml data) returns map<float> {
    map<float> values = {};
    foreach var item in data.children() {
        if (item is xml:Element) {
            string key = item.getName();
            float? value = checkpanic 'float:fromString(item.data());
            if value is float {
                values[key] = value;
            }
        }
    }
    return values;
}

function appendChild(xml:Element parent, xml child) {
    xml children = parent.getChildren();
    parent.setChildren(children + child);
}

function generateGrades(xml rawMarks) returns xml {
    xml:Element grades = xml `<grades/>`;
    foreach var mark in rawMarks.children() {
        if mark is xml:Element {
            xml:Element marksElement = <xml:Element>mark;
            string subject = marksElement.getName();
            int? marks = checkpanic 'int:fromString(marksElement.data());
            if marks is int {

                string grade;
                if (marks >= 85) {
                    grade = "A+";
                } else if (marks >= 75) {
                    grade = "A";
                } else if (marks >= 70) {
                    grade = "A-";
                } else if (marks >= 65) {
                    grade = "B+";
                } else if (marks >= 60) {
                    grade = "B";
                } else if (marks >= 55) {
                    grade = "B-";
                } else if (marks >= 50) {
                    grade = "C+";
                } else if (marks >= 45) {
                    grade = "C";
                } else if (marks >= 40) {
                    grade = "C-";
                } else if (marks >= 35) {
                    grade = "D+";
                } else if (marks >= 30) {
                    grade = "D";
                } else {
                    grade = "F";
                }
                xml:Text gradeElement = xml:createText(grade);
                xml:Element subjectElement = xml:createElement(subject, children = gradeElement);
                appendChild(grades, subjectElement);

            }

        }
    }
    return grades;
}

function setGrades(xml grades) returns map<float> {
    map<float> gradePoints = {
        "A+": 4.0,
        "A": 4.0,
        "A-": 3.7,
        "B+": 3.3,
        "B": 3.0,
        "B-": 2.7,
        "C+": 2.3,
        "C": 2.0,
        "C-": 1.7,
        "D+": 1.3,
        "D": 1.0,
        "F": 0.0
    };
    map<float> gradeMap = {};
    foreach var item in grades.children() {
        if (item is xml:Element) {
            string key = item.getName();
            string grade = item.data();
            float? subjectResult = gradePoints[grade];
            if subjectResult is float {
                gradeMap[key] = subjectResult;
            }
        }
    }
    return gradeMap;
}

@mi:ConnectorInfo {}
public function GPA(xml rawMarks, xml credits) returns xml {

    xml grades = generateGrades(rawMarks);

    // Extract values from the XMLs
    map<float> gradeMap = setGrades(grades);
    map<float> creditMap = extractValues(credits);

    // Calculate total grade points and total credits
    float totalGradePoints = 0;
    float totalCredits = 0;

    foreach var key in gradeMap.keys() {
        float? grade = gradeMap[key];
        float? credit = creditMap[key];
        if grade is float && credit is float {
            totalGradePoints += grade * credit;
            totalCredits += credit;
        }
    }

    // Calculate GPA
    if (totalCredits > 0.0) {
        float gpa = totalGradePoints / totalCredits;
        return xml `<gpa>${gpa}</gpa>`;
    } else {
        return xml `<gpa/>`;
    }
}
