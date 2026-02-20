resource "aws_ecr_repository" "appointment" {
  name                 = "appointmentservice"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_repository" "patient" {
  name                 = "patientservice"
  image_tag_mutability = "MUTABLE"
}