#!/usr/bin/env ruby
#Testing

require 'csv'
require 'yaml'

# Helper script to convert CSV profile data to Jekyll profile pages

def slugify(text)
  text.to_s.downcase.strip.gsub(/[^a-z0-9\s-]/, '').gsub(/\s+/, '-').gsub(/-+/, '-')
end

def get_photo_filename(first_name, last_name)
  # Convert name to expected filename format
  name_slug = "#{first_name.downcase.strip.gsub(/\s+/, '_')}_#{last_name.downcase.strip.gsub(/\s+/, '_')}"
  
  # Check for common extensions in assets/faculty_pictures
  ['jpg', 'jpeg', 'png', 'gif'].each do |ext|
    filename = "#{name_slug}.#{ext}"
    if File.exist?("assets/faculty_pictures/#{filename}")
      return filename
    end
  end
  
  # Return nil if no photo found
  return nil
end

def csv_to_profiles
  csv_file = '_data/profiles.csv'
  profiles_dir = '_profiles'
  
  unless File.exist?(csv_file)
    puts "Error: #{csv_file} not found!"
    return
  end
  
  # Create profiles directory if it doesn't exist
  Dir.mkdir(profiles_dir) unless Dir.exist?(profiles_dir)
  
  # Read CSV and create profile pages
  CSV.foreach(csv_file, headers: true) do |row|
    # Skip Submission column - not needed for display
    first_name = row['First/Given Names (first)']
    last_name = row['Last/Family Name (first)']
    
    next if first_name.nil? || last_name.nil? || first_name.strip.empty? || last_name.strip.empty?
    
    name = "#{first_name} #{last_name}"
    slug = slugify(name)
    filename = "#{profiles_dir}/#{slug}.md"
    
    # Get actual photo filename based on name
    photo_filename = get_photo_filename(first_name, last_name)
    
    # Prepare front matter - map all CSV columns except Submission
    front_matter = {
      'layout' => 'profile',
      'name' => name,
      'first_name' => first_name,
      'last_name' => last_name,
      'email' => row['Email (first)'],
      'website' => row['Website (first)'],
      'institution' => row['Institution'],
      'department' => row['Department'],
      'pronouns' => row['Pronouns'],
      'biography' => row['Biography (Maximum 200 words)'],
      'photo' => photo_filename,
      'linkedin' => row['Link to LinkedIn Profile'],
      'academic_status' => row['Academic Status'],
      'research_area' => row['Research Area/Department (check as many as appropriate)'],
      'degrees_earned' => row['Degrees Earned (Degree/Field/Year)'],
      'research_interests' => row['Please describe your research/academic interests.'],
      'topical_areas' => row['Please select all the topical areas that apply to your project:'],
      'research_synergy' => row['Research Synergy'],
      'motivation' => row['Motivation'],
      'supervising_plan' => row['Supervising Students: Faculty are responsible for supervising their student teams. Describe your plan for working with your student team.'],
      'student_merit' => row['Student Merit: Describe any past experience you have working with the each student on your team, and any other factors, such as their preparedness and/or aptitude, in your decision to include these students on your team.'],
      'lightning_talk_title' => row['Lightning Talk Title (Maximum 10 words)'],
      'keywords' => row['Keywords (Maximum 20 words)']
    }
    
    # Combine First Student and Second Student into student_of_faculty with links
    first_student = row['First Student']
    second_student = row['Second Student']
    students = []
    students << first_student if first_student && !first_student.strip.empty?
    students << second_student if second_student && !second_student.strip.empty?
    
    unless students.empty?
      # Create both the display text and an array of student data for linking
      front_matter['student_of_faculty'] = students.join(', ')
      
      # Create an array of student objects with name and URL
      students_with_links = students.map do |student|
        # Special cases for students with non-standard slugs (3+ words)
        special_slugs = {
          'Teja Vishnu Vardhan Boddu' => 'teja-vishnu-vardhanboddu',
          'Visheshwar Rao Sreekakulapu' => 'visheshwar-raosreekakulapu',
          'MD Saifur Rahman Mazumder' => 'md-saifur-rahmanmazumder',
          'Saikarthik Navuluru' => 'sai-karthiknavuluru',
          'Yesli Linares Lopez' => 'yeslilinares-lopez',
          'Luis Antonio Vela' => 'luis-antoniovela'
        }
        
        if special_slugs[student]
          # Use hardcoded slug for special cases
          student_slug = special_slugs[student]
        elsif student.split.length == 2
          # For two-word names, remove spaces without adding hyphens
          student_slug = student.downcase.gsub(/\s+/, '')
        else
          # For other cases, use standard slugify
          student_slug = slugify(student)
        end
        {
          'name' => student,
          'url' => "https://kevinzhuang01.github.io/students_of_fac/profiles/#{student_slug}/"
        }
      end
      front_matter['students_list'] = students_with_links
    end
    
    # Remove empty fields (but keep arrays)
    front_matter.reject! { |k, v| v.nil? || (v.is_a?(String) && v.strip.empty?) }
    
    # Create the profile page content
    content = "---\n"
    content += front_matter.to_yaml.gsub(/^---\n/, '')
    content += "---\n"
    
    # Write the file
    File.write(filename, content)
    puts "Created: #{filename}"
  end
  
  puts "\nProfile pages generated successfully!"
  puts "Remember to add profile images to the assets/images/ directory."
end

def csv_to_yaml
  csv_file = '_data/profiles.csv'
  yaml_file = '_data/profiles.yml'
  
  unless File.exist?(csv_file)
    puts "Error: #{csv_file} not found!"
    return
  end
  
  profiles = []
  CSV.foreach(csv_file, headers: true) do |row|
    profile = {}
    row.headers.each do |header|
      value = row[header]
      profile[header] = value if value && !value.strip.empty?
    end
    profiles << profile unless profile.empty?
  end
  
  File.write(yaml_file, profiles.to_yaml)
  puts "Created: #{yaml_file}"
end

# Main execution
if ARGV.include?('--yaml-only')
  csv_to_yaml
else
  csv_to_profiles
  csv_to_yaml
end
