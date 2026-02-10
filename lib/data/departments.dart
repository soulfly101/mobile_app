class Department {
  final String name;
  final String location;
  final String phone;
  final String description;

  Department({
    required this.name,
    required this.location,
    required this.phone,
    required this.description,
  });
}

final List<Department> departments = [
  Department(
    name: "Computer Science",
    location: "Block B",
    phone: "+233 20 000 0001",
    description: "Computing and software programs.",
  ),
  Department(
    name: "Information Technology",
    location: "Block C",
    phone: "+233 20 000 0002",
    description: "IT and applied technologies.",
  ),
  Department(
    name: "Engineering",
    location: "North Campus",
    phone: "+233 20 000 0003",
    description: "Engineering programs and lab-based learning.",
  ),
];
