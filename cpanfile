requires "Bubblegum" => "0.21";
requires "Class::Load" => "0.21";
requires "DateTime::Tiny" => "1.04";
requires "Exporter::Tiny" => "0.036";
requires "File::Find::Rule" => "0.33";
requires "File::HomeDir" => "1.00";
requires "File::Spec" => "3.40";
requires "File::Which" => "1.09";
requires "Hash::Merge::Simple" => "0.051";
requires "Path::Tiny" => "0.052";
requires "Time::Format" => "1.12";
requires "Time::ParseDate" => "2013.1113";
requires "Try::Tiny" => "0.19";
requires "Type::Tiny" => "0.040";
requires "perl" => "v5.10.0";

on 'configure' => sub {
  requires "ExtUtils::MakeMaker" => "6.30";
};
