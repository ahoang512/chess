class Employee
  attr_reader :name, :title, :salary, :boss

  def initialize(name, title, salary, boss)
      @name = name
      @title = title
      @salary = salary
      @boss = boss
  end

  def bonus(multi)
    salary * multi
  end
end

class Manager < Employee
  attr_reader :employees

  def initialize(name, title, salary, boss, employees)
    super(name, title, salary, boss)
    @employees = employees
  end

  def bonus(multi)
    queue = employees
    sum = 0

    until queue.empty?
      current_employee = queue.shift
      sum += current_employee.salary
      if current_employee.is_a?(Manager)
        queue = queue + current_employee.employees
      end
    end
    sum * multi
  end
end
